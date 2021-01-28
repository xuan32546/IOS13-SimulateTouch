#import "ActivatorListener.h"
#include "../Task.h"
#include "../Config.h"
#import "../ScriptPlayer.h"

extern ScriptPlayer* scriptPlayer;

@implementation ActivatorListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	// read config file
    NSDictionary* config = [[NSDictionary alloc] initWithContentsOfFile:ACTIVATOR_CONFIG_PATH];

    if (!config)
    {
        NSLog(@"com.zjx.springboard: activator config file not found!");
        return;
    }

    NSDictionary* autorunDict = [config objectForKey:@"autorun"];
    if (!autorunDict)
    {
        NSLog(@"com.zjx.springboard: config file found but autorun field is nil!");
        return;
    }

    NSString* scriptPath = [autorunDict objectForKey:event.name];
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


	[event setHandled:YES]; // To prevent the default OS implementation
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