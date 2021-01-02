#line 1 "Screen.xm"
#include "Screen.h"
#include "Common.h"

static CGFloat device_screen_width = 0;
static CGFloat device_screen_height = 0;


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
#line 7 "Screen.xm"
@implementation Screen
{
    
}






+ (void)setScreenSize:(CGFloat)x height:(CGFloat) y {
	device_screen_width = x;
	device_screen_height = y;

	if (device_screen_width == 0 || device_screen_height == 0 || device_screen_width > 10000 || device_screen_height > 10000)
	{
		NSLog(@"### com.zjx.springboard: Unable to initialze the screen size. screen width: %f, screen height: %f", device_screen_width, device_screen_height);
	}
	else
	{
		NSLog(@"### com.zjx.springboard: successfully initialize the screen size. screen width: %f, screen height: %f", device_screen_width, device_screen_height);
	}
}


+ (int)getScreenOrientation {
    __block int screenOrientation = -1;

    dispatch_sync(dispatch_get_main_queue(), ^{
        @try{
            SpringBoard *springboard = (SpringBoard*)[_logos_static_class_lookup$SpringBoard() sharedApplication];
            screenOrientation = [springboard _frontMostAppOrientation];
            
        }
        @catch (NSException *exception) {
            NSLog(@"com.zjx.springboard: Debug: %@", exception.reason);
        }
    }   
    );

    return screenOrientation;
}


+ (CGFloat)getScreenWidth {
    if (device_screen_width == 0)
    {
        NSLog(@"com.zjx.springboard: Cannot get screen width. Maybe you call [Screen getScreenWidth] before springboard getting the screen size.");
    }
    return device_screen_width;
}


+ (CGFloat)getScreenHeight {
    if (device_screen_height == 0)
    {
        NSLog(@"com.zjx.springboard: Cannot get screen height. Maybe you call [Screen getScreenHeight] before springboard getting the screen size.");
    }
    return device_screen_height;
}


+ (CGFloat)getScale {    
    return [[UIScreen mainScreen] scale];
}
@end
#line 73 "Screen.xm"
