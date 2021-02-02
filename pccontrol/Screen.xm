#include "Screen.h"
#include "Common.h"

static CGFloat device_screen_width = 0;
static CGFloat device_screen_height = 0;

@implementation Screen
{
    // device screen size
}


/*
Get the size of the screen and set them.
*/
+ (void)setScreenSize:(CGFloat)x height:(CGFloat) y
{
	device_screen_width = x;
	device_screen_height = y;

	if (device_screen_width == 0 || device_screen_height == 0 || device_screen_width > 10000 || device_screen_height > 10000)
	{
		NSLog(@"com.zjx.springboard: Unable to initialze the screen size. screen width: %f, screen height: %f", device_screen_width, device_screen_height);
	}
	else
	{
		NSLog(@"com.zjx.springboard: successfully initialize the screen size. screen width: %f, screen height: %f", device_screen_width, device_screen_height);
	}
}

+ (int)getScreenOrientation
{
    __block int screenOrientation = -1;

    dispatch_sync(dispatch_get_main_queue(), ^{
        @try{
            SpringBoard *springboard = (SpringBoard*)[%c(SpringBoard) sharedApplication];
            screenOrientation = [springboard _frontMostAppOrientation];
            //NSLog(@"com.zjx.springboard: orientation %d", screenOrientation);
        }
        @catch (NSException *exception) {
            NSLog(@"com.zjx.springboard: Debug: %@", exception.reason);
        }
    }   
    );

    return screenOrientation;
}

+ (CGFloat)getScreenWidth
{
    if (device_screen_width == 0)
    {
        NSLog(@"com.zjx.springboard: Cannot get screen width. Maybe you call [Screen getScreenWidth] before springboard getting the screen size.");
    }
    return device_screen_width;
}

+ (CGFloat)getScreenHeight
{
    if (device_screen_height == 0)
    {
        NSLog(@"com.zjx.springboard: Cannot get screen height. Maybe you call [Screen getScreenHeight] before springboard getting the screen size.");
    }
    return device_screen_height;
}

+ (CGFloat)getScale
{    
    return [[UIScreen mainScreen] scale];
}

+ (CGRect)getBounds
{
    return [UIScreen mainScreen].bounds;
}

OBJC_EXTERN UIImage *_UICreateScreenUIImage(void);
+ (NSString*)screenShot
{
     UIImage *screenImage = _UICreateScreenUIImage();
    // Create path.
    NSString *filePath = [getDocumentRoot() stringByAppendingPathComponent:@"screenshot.jpg"];

    // Save image.
    [UIImageJPEGRepresentation(screenImage, 0.7) writeToFile:filePath atomically:true];

    return filePath;
}

+ (NSString*)screenShotAlwaysUp
{
     UIImage *screenImage = _UICreateScreenUIImage();
    int orientation = [self getScreenOrientation];

    UIImageOrientation after = UIImageOrientationUp;
    if (orientation == 4)
    {
        after = UIImageOrientationRight;
    }
    else if (orientation == 3)
    {
        after = UIImageOrientationLeft;
    }
    else if (orientation == 2)
    {
        after = UIImageOrientationDown;
    }

    UIImage *result = [UIImage imageWithCGImage:[screenImage CGImage]
              scale:[screenImage scale]
              orientation: after];

    // Create path.
    NSString *filePath = [getDocumentRoot() stringByAppendingPathComponent:@"screenshot.jpg"];

    // Save image.
    [UIImageJPEGRepresentation(result, 0.7) writeToFile:filePath atomically:true];

    return filePath;
}
@end