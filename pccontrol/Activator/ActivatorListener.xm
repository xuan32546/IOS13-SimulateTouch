#import "ActivatorListener.h"
#include "../Task.h"
#include "../Config.h"
#import "../ScriptPlayer.h"
#import "../Play.h"
#import "../Popup.h"

#define AUTORUN 1
#define SHOW_POPUP 2
#define STOP_PLAYING_ALL 3

extern ScriptPlayer* scriptPlayer;
extern PopupWindow *popupWindow;



@implementation ActivatorListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	// read config file
    NSDictionary* config = [[NSDictionary alloc] initWithContentsOfFile:ACTIVATOR_CONFIG_PATH];
    NSLog(@"com.zjx.springboard: 123");
    if (!config)
    {
        NSLog(@"com.zjx.springboard: activator config file not found!");
        return;
    }

    NSDictionary* eventInfo = [config objectForKey:event.name];
    if (!eventInfo)
    {
        NSLog(@"com.zjx.springboard: config file found but no entry for current event!");
        return;
    }

    // get task type
    int type = [eventInfo[@"type"] intValue];
    [event setHandled:YES]; // To prevent the default OS implementation

    if (type == AUTORUN)
    {
        NSString* scriptPath = [eventInfo objectForKey:@"user_info"];
        if (!scriptPath || [scriptPath isEqualToString:@""])
        {
            NSLog(@"com.zjx.springboard: activator event not assigned to any script!");
            return;
        }

        if (![scriptPlayer isPlaying])
        {
            // run the script
            processTask((UInt8*)[[NSString stringWithFormat:@"19%@", scriptPath] UTF8String], NULL);
        }
        else if ([[scriptPlayer getCurrentBundlePath] isEqualToString:scriptPath])
        {
            processTask((UInt8*)"20", NULL);
        }
    }
    else if (type == SHOW_POPUP)
    {
        if (![popupWindow isShown])
        {
            [popupWindow show];
        }
        else
        {
            [popupWindow hide];
        }
    }
    else if (type == STOP_PLAYING_ALL)
    {
        NSError *err = nil;
        stopScriptPlaying(&err);
    }
    else
    {
        NSLog(@"com.zjx.springboard: activator unknown event type.");
        [event setHandled:NO];
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	// Dismiss your plugin
}

+ (void)load {
	if ([LASharedActivator isRunningInsideSpringBoard]) {
		[LASharedActivator registerListener:[self new] forName:@"com.zjx.zxtouch"];
	}
}

@end