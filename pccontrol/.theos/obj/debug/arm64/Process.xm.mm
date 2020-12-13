#line 1 "Process.xm"
#include "Process.h"
int (*openApp)(CFStringRef, Boolean);

static void* sbServices = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);

int switchProcessForegroundFromRawData(UInt8 *eventData)
{
    return bringAppForeground([NSString stringWithFormat:@"%s", eventData]);
}

int bringAppForeground(NSString *appIdentifier)
{
    CFStringRef appBundleName = CFStringCreateWithFormat(NULL, NULL, CFSTR("%@"), appIdentifier);
    
    NSLog(@"### com.zjx.springboard: Switch to application: %@", appBundleName);
    if (!openApp)
        openApp = (int(*)(CFStringRef, Boolean))dlsym(sbServices,"SBSLaunchApplicationWithIdentifier");

    return openApp(appBundleName, false);
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SpringBoard(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SpringBoard"); } return _klass; }
#line 22 "Process.xm"
id getFrontMostApplication()
{
    
    __block id app = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        @try{
            SpringBoard *springboard = (SpringBoard*)[_logos_static_class_lookup$SpringBoard() sharedApplication];
            app = [springboard _accessibilityFrontMostApplication];
            
        }
        @catch (NSException *exception) {
            NSLog(@"com.zjx.springboard: Debug: %@", exception.reason);
        }
        });
    return app;
}
#line 38 "Process.xm"
