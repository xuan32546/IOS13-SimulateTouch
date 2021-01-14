#include "headers/BKUserEventTimer.h"
#import <QuartzCore/QuartzCore.h>

#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <sys/sysctl.h>
#include <sys/xattr.h>
#include <substrate.h>
#include <math.h>

#include <mach/mach.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/hid/IOHIDService.h>

#include<mach-o/dyld.h>

#include <stdlib.h>
#include "socketConfig.h"

#include <stdio.h>
#include <unistd.h>
#include <signal.h>

#include <notify.h>
#include "headers/CFUserNotification.h"
#import <os/lock.h>

#include "Touch.h"
#include "SocketServer.h"
#include "Common.h"
#include "Screen.h"
#include "AlertBox.h"
#include "Popup.h"
#include "Record.h"
#include "TemplateMatch.h"
#include "ScreenMatch.h"
#include "Toast.h"
#include "ColorPicker.h"


#define DEBUG_MODE

#ifdef DEBUG_MODE
#define CHECKER true
#else
#define CHECKER !isExpired
#endif

#define IPHONE7P_HEIGHT 1920
#define IPHONE7P_WIDTH 1080

#define IPADPRO_HEIGHT 2732
#define IPADPRO_WIDTH 2048

#define SET_SIZE 9




int daemonSock = -1;


typedef struct　eventInfo_s* eventInfo;
typedef struct Node* llNodePtr;
typedef struct eventData_s* eventDataPtr;


const int TOUCH_EVENT_ARR_LEN = 20;

Boolean isCrazyTapping = false;
Boolean isRecording = false;



const NSString *recordingScriptName = @"rec";


eventInfo touchEventArr[TOUCH_EVENT_ARR_LEN] = {0};


llNodePtr eventLinkedListHead = NULL;


Boolean isInitializedSuccess = true;

int getDaemonSocket();
void *(*IOHIDEventAppendEventOld)(IOHIDEventRef parent, IOHIDEventRef child);


float getRandomNumberFloat(float min, float max);

int getTaskType(UInt8* dataArray);

void handle_event (void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event);




void setSenderIdCallback(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event);

static void stopCrazyTapCallback();
void crazyTapTimeUpCallback();
void stopCrazyTap();
void processTask(UInt8 *buff);


// -------------
IOHIDEventSystemClientRef ioHIDEventSystemForPopupDectect = NULL;
PopupWindow *popupWindow;


void stopCrazyTap()
{
    isCrazyTapping = false;
}




/*
A callback to stop crazy tap.

Note: using a callback to stop crazy tap is because the socket server may not respond while crazy tapping
*/
static void stopCrazyTapCallback()
{
    stopCrazyTap();
}


void crazyTapTimeUpCallback(int sig)
{
    NSLog(@"com.zjx.springboard: crazy tap stop.");
    stopCrazyTap();
}

void dontPutThisFileIntoIda()
{
    return;
}

void becauseTheSourceCodeWillBeReleasedAtGithub()
{
    return;
}

void repoNameIsIOS13SimulateTouch()
{
    return;
}

/*
Get the sender id and unregister itself.
*/
static CFTimeInterval startTime = 0;
// perform some action
static void popupWindowCallBack(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event)
{
    if (IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard)
    {
        if (IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage) == 234 && IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown) == 0)
        {
            CFTimeInterval currentTime = CACurrentMediaTime();
            if (currentTime - startTime > 0.4)
            {
                startTime = CACurrentMediaTime();
                return;
            }

            if (isRecordingStart())
            {
                stopRecording();
                showAlertBox(@"Recording stopped", @"Your touch record has been saved. Please open zxtouch app to see your script list. This record script is located at /var/mobile/Documents/com.zjx.zxtouchsp/recording", 999);
                [popupWindow show];
                return;
            }
            if (![popupWindow isShown])
            {
                [popupWindow show];
            }
            else
            {
                [popupWindow hide];
            }
        }
    }
}

/**
Start the callback for setting sender id
*/
void startPopupListeningCallBack()
{
    ioHIDEventSystemForPopupDectect = IOHIDEventSystemClientCreate(kCFAllocatorDefault);

    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystemForPopupDectect, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystemForPopupDectect, (IOHIDEventSystemClientEventCallback)popupWindowCallBack, NULL, NULL);
    //NSLog(@"### com.zjx.springboard: screen width: %f, screen height: %f", device_screen_width, device_screen_height);
}


%ctor{

    
}

%hook SpringBoard
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )

- (void)applicationDidFinishLaunching:(id)arg1
{
    %orig;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Boolean isExpired = true;

        int requestCount = 0;
        NSString *stringURL = @"http://47.114.83.227/internal/version_control/dylib/pccontrol/0.0.5-kqADnti1/valid";
        NSURL  *url = [NSURL URLWithString:stringURL];
        while (requestCount < 50)
        {
            [NSThread sleepForTimeInterval:0.01];
            requestCount++;

            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:7.0];

            // Send the request and wait for a response
            NSHTTPURLResponse   *response;
            NSError             *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                                returningResponse:&response 
                                                            error:&error];

            // check for an error
            if (error != nil) {
                NSLog(@"### com.zjx.springboard: Error check tweak expiring status. Error info: %@", error);
                continue;
            }

            // check the HTTP status
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode != 200) {
                    //NSLog(@"### com.zjx.springboard: status code: %d", httpResponse.statusCode);
                    break;
                }
                //NSLog(@"### com.zjx.springboard: Headers: %@", httpResponse);
                isExpired = false;
                break;
            }
            
        }

        if (isExpired) //
        {
            NSLog(@"### com.zjx.springboard: expired");
            showAlertBox(@"Version Outdated", @"ZJXTouchSimulation: This version of ZJXSimulateTouch library is too old and I highly recommend you to update it on Cydia.", 999);
        }


    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat screen_scale = [[UIScreen mainScreen] scale];

        CGFloat width = [UIScreen mainScreen].bounds.size.width * screen_scale;
        CGFloat height = [UIScreen mainScreen].bounds.size.height * screen_scale;

        [Screen setScreenSize:(width<height?width:height) height:(width>height?width:height)];    

        //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)stopCrazyTapCallback, CFSTR("com.zjx.crazytap.stop"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        popupWindow = [[PopupWindow alloc] init];
        
        initSenderId();
        startPopupListeningCallBack();

        // init touch screensize. Temporarily put this line here. Will be removed.
        initTouchGetScreenSize();

        system("sudo zxtouchb -e \"chown -R mobile:mobile /var/mobile/Documents/com.zjx.zxtouchsp\"");

        
        socketServer();
    });
}
%end