#include "Screen.h"
#include "Common.h"


#include "headers/IOSurface/IOSurfaceAccelerator.h"
#include "headers/IOSurface/IOMobileFramebuffer.h"
#import "headers/IOSurface/IOSurface.h"
#include "headers/IOSurface/CoreSurface.h"

OBJC_EXTERN void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);
OBJC_EXTERN kern_return_t IOSurfaceLock(IOSurfaceRef buffer, IOSurfaceLockOptions options, uint32_t *seed);
OBJC_EXTERN kern_return_t IOSurfaceUnLock(IOSurfaceRef buffer, IOSurfaceLockOptions options, uint32_t *seed);
OBJC_EXTERN IOSurfaceRef IOSurfaceCreate(CFDictionaryRef dictionary);
OBJC_EXTERN CGImageRef UICreateCGImageFromIOSurface(IOSurfaceRef surface);

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
    NSString *filePath = [getDocumentRoot() stringByAppendingPathComponent:@"screenshot.png"];

    // Save image.
    [UIImagePNGRepresentation(screenImage) writeToFile:filePath atomically:NO];
    return filePath;
}

+ (UIImage*)screenShotUIImage // memory leak, need to be fixed
{
    return _UICreateScreenUIImage();
}

+ (CGImageRef)createScreenShotCGImageRef
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    int height = (int)(screenSize.height * scale);
    int width = (int)(screenSize.width * scale);

    int bytesPerElement = 4;
    int bytesPerRow = roundUp(bytesPerElement * width, 32);

    NSNumber *IOSurfaceBytesPerElement = [NSNumber numberWithInteger:bytesPerElement]; 
    NSNumber *IOSurfaceBytesPerRow = [NSNumber numberWithInteger:bytesPerRow]; // don't know why but it should be a multiple of 32
    NSNumber *IOSurfaceAllocSize = [NSNumber numberWithInteger:bytesPerRow * height]; 
    NSNumber *nheight = [NSNumber numberWithInteger:height]; 
    NSNumber *nwidth = [NSNumber numberWithInteger:width]; 
    NSNumber *IOSurfacePixelFormat = [NSNumber numberWithInteger:1111970369]; 
    NSNumber *IOSurfaceIsGlobal = [NSNumber numberWithInteger:1]; 

    NSDictionary *properties = [[NSDictionary alloc] initWithObjectsAndKeys:IOSurfaceAllocSize, @"IOSurfaceAllocSize"
                                , IOSurfaceBytesPerElement, @"IOSurfaceBytesPerElement", IOSurfaceBytesPerRow, @"IOSurfaceBytesPerRow", nheight, @"IOSurfaceHeight", 
                                IOSurfaceIsGlobal, @"IOSurfaceIsGlobal", IOSurfacePixelFormat, @"IOSurfacePixelFormat", nwidth, @"IOSurfaceWidth", nil];    

    IOSurfaceRef screenSurface = IOSurfaceCreate((__bridge CFDictionaryRef)(properties));

    properties = nil;
    
    IOSurfaceLock(screenSurface, 0, NULL);
    CARenderServerRenderDisplay(0, CFSTR("LCD"), screenSurface, 0, 0);
        
    CGImageRef cgImageRef = nil;
    if (screenSurface) {
        cgImageRef = UICreateCGImageFromIOSurface(screenSurface);
    }
    IOSurfaceUnlock(screenSurface, 0, NULL);
    CFRelease(screenSurface);
    screenSurface = nil;

    return cgImageRef;
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
    NSString *filePath = [getDocumentRoot() stringByAppendingPathComponent:@"screenshot.png"];

    // Save image.
    [UIImagePNGRepresentation(result) writeToFile:filePath atomically:NO];
    return filePath;
}
@end