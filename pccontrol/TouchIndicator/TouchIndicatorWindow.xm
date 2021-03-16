#include "TouchIndicatorWindow.h"
#include "TouchIndicatorViewList.h"
#include "../Screen.h"
#include "../AlertBox.h"
#include "../Common.h"

#import "TouchIndicatorView.h"
#import "TouchIndicatorCoordinateView.h"

#include "../headers/IOHIDEvent.h"
#include "../headers/IOHIDEventData.h"
#include "../headers/IOHIDEventTypes.h"
#include "../headers/IOHIDEventSystemClient.h"
#include "../headers/IOHIDEventSystem.h"
#import <mach/mach.h>

#define HIDE 0
#define SHOW 1
#define RELOAD 2

//#define COORDINATE_VIEW_WIDTH 100
#define COORDINATE_VIEW_HEIGHT 20


static Boolean isShowing = false;

static void IOHIDEventCallbackForTouchIndicator(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef parentEvent);

static IOHIDEventSystemClientRef ioHIDEventSystemClient = NULL;
static CFRunLoopRef runLoopRef = NULL;



static CGFloat screenBoundsWidth = 0;
static CGFloat screenBoundsHeight = 0;
static CGFloat scale = 0;

static TouchIndicatorWindow *touchIndicatorWindow;

void report_memory(void) {
  struct task_basic_info info;
  mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
  kern_return_t kerr = task_info(mach_task_self(),
                                 TASK_BASIC_INFO,
                                 (task_info_t)&info,
                                 &size);
  if( kerr == KERN_SUCCESS ) {
    NSLog(@"com.zjx.springboard: Memory in use (in bytes): %lu", info.resident_size);
    NSLog(@"com.zjx.springboard: Memory in use (in MiB): %f", ((CGFloat)info.resident_size / 1048576));
  } else {
    NSLog(@"com.zjx.springboard: Error with task_info(): %s", mach_error_string(kerr));
  }
}


void handleTouchIndicatorTaskWithRawData(UInt8* eventData, NSError **error)
{
    if ([[NSString stringWithFormat:@"%s", eventData] intValue] == HIDE)
    {
        stopTouchIndicator(error);
    }
    else if ([[NSString stringWithFormat:@"%s", eventData] intValue] == SHOW)
    {
        startTouchIndicator(error);
    }
    else if ([[NSString stringWithFormat:@"%s", eventData] intValue] == RELOAD)
    {
        if (!isShowing)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Cannot reload config file because the touch indicator is not showing.\r\n"}];
            return;
        }
        // check whether config file exist
        NSString *configFilePath = getCommonConfigFilePath();

        if (![[NSFileManager defaultManager] fileExistsAtPath:configFilePath])
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to show touch indicator because the configuration file is missing. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.\r\n"}];
            showAlertBox(@"Error", @"Unable to show touch indicator because the configuration file is missing. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.", 999);
            return;
        }
        // read indicator color from the config file
        NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];

        CGFloat red = 0;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0.5f;

        @try {
            red = [config[@"touch_indicator"][@"color"][@"r"] floatValue];
            green = [config[@"touch_indicator"][@"color"][@"g"] floatValue];
            blue = [config[@"touch_indicator"][@"color"][@"b"] floatValue];
            alpha = [config[@"touch_indicator"][@"color"][@"alpha"] floatValue];
            NSLog(@"com.zjx.springboard: reload touch indicator. Read color: red: %f, g: %f, b: %f", red, green, blue);
        }
        @catch (NSException *exception) {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Unable to show touch indicator because key error in configuration file: %@. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.\r\n", exception]}];
            showAlertBox(@"Error", [NSString stringWithFormat:@"Unable to show touch indicator because key error in configuration file: %@. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.", exception], 999);
            return;
        }

        [touchIndicatorWindow setIndicatorColorWithRed:red green:green blue:blue alpha:alpha];
    }
    else
    {
        NSLog(@"com.zjx.springboard: Unknown touch indicator data");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unknown touch indicator data\r\n"}];
        return;
    }

}

void stopTouchIndicator(NSError **error)
{
    NSLog(@"com.zjx.springboard: Touch indicator turn off request");
    // set touch indicator window to nil
    touchIndicatorWindow = nil;
    // unregister callback
    if (ioHIDEventSystemClient && runLoopRef)
    {
        IOHIDEventSystemClientUnregisterEventCallback(ioHIDEventSystemClient);
        IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDEventSystemClient, runLoopRef, kCFRunLoopDefaultMode);

        ioHIDEventSystemClient = NULL;

        CFRunLoopStop(runLoopRef);
        runLoopRef = NULL;
    }

    isShowing = false;
}



void startTouchIndicator(NSError **error)
{
    if (isShowing)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Touch indicator is already showing\r\n"}];
        showAlertBox(@"Error", @"Touch indicator is already showing", 999);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"com.zjx.springboard: Touch indicator turn on request");

        // check whether config file exist
        NSString *configFilePath = getCommonConfigFilePath();

        CGFloat red = 255;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0.7f;

        if ([[NSFileManager defaultManager] fileExistsAtPath:configFilePath])
        {
            /*
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to show touch indicator because the configuration file is missing. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.\r\n"}];
            showAlertBox(@"Error", @"Unable to show touch indicator because the configuration file is missing. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.", 999);
            return;
            */
                    // read indicator color from the config file
            NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];

            @try {
                red = [config[@"touch_indicator"][@"color"][@"r"] floatValue];
                green = [config[@"touch_indicator"][@"color"][@"g"] floatValue];
                blue = [config[@"touch_indicator"][@"color"][@"b"] floatValue];
                alpha = [config[@"touch_indicator"][@"color"][@"alpha"] floatValue];
                NSLog(@"com.zjx.springboard: red: %f, g: %f, b: %f", red, green, blue);
            }
            @catch (NSException *exception) {
                NSLog(@"com.zjx.springboard: 123123");
                *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Unable to show touch indicator because key error in configuration file: %@. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.\r\n", exception]}];
                showAlertBox(@"Error", [NSString stringWithFormat:@"Unable to show touch indicator because key error in configuration file: %@. Please go to \"zxtouch - settings - fix configuration\" to fix this problem.", exception], 999);
                return;
            }
        }


        // get screen size
        CGRect bounds = [Screen getBounds];
        scale = [Screen getScale];
        screenBoundsWidth = CGRectGetWidth(bounds);
        screenBoundsHeight = CGRectGetHeight(bounds);

        if (screenBoundsWidth > screenBoundsHeight)
            swapCGFloat(&screenBoundsWidth, &screenBoundsHeight);

        if (screenBoundsWidth == 0 || screenBoundsHeight == 0)
        {
            showAlertBox(@"Error", @"Cannot get screen bound.", 999);
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Cannot get screen bound\r\n"}];
            return;
        }

        // init a touch indicator window
        
        touchIndicatorWindow = [[TouchIndicatorWindow alloc] init];
        [touchIndicatorWindow show];
        
        // create callback
        ioHIDEventSystemClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
        

        IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystemClient, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystemClient, (IOHIDEventSystemClientEventCallback)IOHIDEventCallbackForTouchIndicator, NULL, NULL);
        
        isShowing = true;

        runLoopRef = CFRunLoopGetCurrent();

        CFRunLoopRun();
        
    });
}

static void IOHIDEventCallbackForTouchIndicator(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef parentEvent) 
{
    
    if (IOHIDEventGetType(parentEvent) == kIOHIDEventTypeDigitizer){
        if (!touchIndicatorWindow)
        {
            return;
        }

        
    if (IOHIDEventGetType(parentEvent) == kIOHIDEventTypeDigitizer)
    {
        NSArray *childrens = (__bridge NSArray *)IOHIDEventGetChildren(parentEvent);

        for (int i = 0; i < [childrens count]; i++)
        {
            Boolean print = false;
            IOHIDEventRef event = (__bridge IOHIDEventRef)childrens[i];
            IOHIDFloat x = IOHIDEventGetFloatValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerX);
            IOHIDFloat y = IOHIDEventGetFloatValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerY);
            int eventMask = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerEventMask);
            int range = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerRange);
            int touch = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerTouch);
            int index = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerIndex);
            //NSLog(@"### com.zjx.springboard: x %f : y %f. eventMask: %d. index: %d, range: %d. Touch: %d", x, y, eventMask, index, range, touch);
            //NSLog(@"### com.zjx.springboard:  x %f : y %f. eventMask: %d. index: %d, range: %d. Touch: %d.", x, y, eventMask, index, range, touch);

            IOHIDFloat majorRadius = IOHIDEventGetFloatValue(event, 0xb0014);

            CGFloat xOnScreen = x * screenBoundsWidth;
            CGFloat yOnScreen = y * screenBoundsHeight;

            if ( touch == 1 && eventMask & 2 )
                // touch down
                [touchIndicatorWindow showIndicator:index withX:xOnScreen andY:yOnScreen majorRadius:majorRadius];
            else if ( touch == 1 && eventMask & 4 )
                // touch move
                [touchIndicatorWindow moveIndicator:index x:xOnScreen y:yOnScreen majorRadius:majorRadius];

            else if (!touch && (eventMask & 2) )
                // touch up
                [touchIndicatorWindow hideIndicator:index];
            }
        }
    }
    
}


@implementation TouchIndicatorWindow
{
    UIWindow *_window;
    //TouchIndicatorViewList* indicatorViewList;
    TouchIndicatorView* touchIndicatorViewList[20];
    TouchIndicatorCoordinateView* coordinateView[20];
    UIColor* indicatorColor;
}

- (id)init {
    self = [super init];
    if (self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenBoundsWidth, screenBoundsHeight)];
            _window.windowLevel = UIWindowLevelAlert;
            [_window setBackgroundColor:[UIColor clearColor]];
            [_window setUserInteractionEnabled:NO];
            [_window setAutoresizingMask:18];

            indicatorColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.5];
            //init indicator view list
            //indicatorViewList = [[TouchIndicatorViewList alloc] init];
            
            /*
            for (int i = 0; i < 20; i++)
            {

            }
            */

        });
    }
    return self;
}


- (void)hideIndicator:(int)index {
    if (index >= 20)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [touchIndicatorViewList[index-1] removeFromSuperview];
        touchIndicatorViewList[index-1] = nil;

        [coordinateView[index-1] removeFromSuperview];
        coordinateView[index-1] = nil;
    });
}

- (void)showIndicator:(int)index withX:(int)x andY:(int)y majorRadius:(CGFloat)radius {    
    if (index >= 20)
    {
        return;
    }
    if (touchIndicatorViewList[index-1] != nil)
    {
        [self hideIndicator:index];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat indicatorSize = radius*SIZE_INDIACTOR_TOUCH_RADIUS_RATIO;
        // init a indicator
        CGFloat halfSize = indicatorSize/2;
        TouchIndicatorView *indicator = [[TouchIndicatorView alloc] initWithFrame:CGRectMake(x - halfSize, y - halfSize, indicatorSize, indicatorSize)];
        indicator.layer.cornerRadius = halfSize;
        indicator.backgroundColor = indicatorColor;

        // create touch coordinate view
        NSString *coordinateText = [NSString stringWithFormat:@"(%d, %d)", (int)(x * scale), (int)(y * scale)];
        UIFont *font = [UIFont fontWithName: @"Trebuchet MS" size: 11.0f];
        CGSize stringSize = [coordinateText sizeWithFont:font]; 
        CGFloat stringWidth = stringSize.width;

        TouchIndicatorCoordinateView *coordinateLabelView = [[TouchIndicatorCoordinateView alloc] initWithFrame:CGRectMake(x + halfSize + 5, y, stringWidth+5, COORDINATE_VIEW_HEIGHT)];
        coordinateLabelView.backgroundColor = indicatorColor;


        UILabel *coordinateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, stringWidth+5, COORDINATE_VIEW_HEIGHT)];
        coordinateLabel.text = coordinateText;
        [coordinateLabel setTextColor:[UIColor whiteColor]];
        [coordinateLabel setBackgroundColor:[UIColor clearColor]];
        [coordinateLabel setFont:font]; 
        [coordinateLabelView addSubview:coordinateLabel];
        coordinateLabelView.coordinateLabel = coordinateLabel;

        // add to list
        touchIndicatorViewList[index-1] = indicator;
        coordinateView[index-1] = coordinateLabelView;
        
        // add to subview
        [_window addSubview:indicator];
        [_window addSubview:coordinateLabelView];

        //[indicator setHidden:YES];
    });
}

- (void) show {
    dispatch_async(dispatch_get_main_queue(), ^{
        _window.hidden = NO;
    });
}

- (void) hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        _window.hidden = YES;
    });
}


- (void)setIndicatorColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    indicatorColor = [UIColor colorWithRed:red/255 green:green/255 blue:blue/255 alpha:alpha];
}


- (void)moveIndicator:(int)index x:(CGFloat)x y:(CGFloat)y majorRadius:(CGFloat)radius {
    if (index >= 20)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (touchIndicatorViewList[index-1] == NULL)
            return;

        // update width and height and cornerRadius
        CGFloat indicatorSize = radius*SIZE_INDIACTOR_TOUCH_RADIUS_RATIO;
        CGFloat halfSize = indicatorSize/2;
        touchIndicatorViewList[index-1].frame = CGRectMake(x - halfSize, y - halfSize, indicatorSize, indicatorSize);
        touchIndicatorViewList[index-1].layer.cornerRadius = halfSize;

        NSString *coordinateText = [NSString stringWithFormat:@"(%d, %d)", (int)(x*scale), (int)(y*scale)];
        UIFont *font = [UIFont fontWithName: @"Trebuchet MS" size: 11.0f];
        CGSize stringSize = [coordinateText sizeWithFont:font]; 
        CGFloat stringWidth = stringSize.width;

        coordinateView[index-1].coordinateLabel.text = coordinateText;

        coordinateView[index-1].coordinateLabel.frame = CGRectMake(0, 0, stringWidth+5, COORDINATE_VIEW_HEIGHT);
        coordinateView[index-1].frame =  CGRectMake(x + halfSize + 5, y, stringWidth+5, COORDINATE_VIEW_HEIGHT);
    });
}

@end
