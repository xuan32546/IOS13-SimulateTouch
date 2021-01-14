#import "Toast.h"
#import "Screen.h"
#import <mach/mach.h>

static int windowWidth = 200;
static int windowHeight = 200;
static NSDictionary* backgroundColorDict = @{@"4":[UIColor colorWithRed:0.282f green:0.78f blue:0.45f alpha:1.0f], @"1":[UIColor colorWithRed:0.945f green:0.275f blue:0.408f alpha:1.0f],@"2":[UIColor colorWithRed:1.0f green:0.867f blue:0.341f alpha:1.0f],@"3":[UIColor whiteColor]};
static NSDictionary* fontColorDict = @{@"4":[UIColor whiteColor], @"1":[UIColor whiteColor],@"2":[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f],@"3":[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]};
static UIWindow *_window;
void showToastFromRawData(UInt8 *eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];
    if ([data count] < 3)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;The data format should be \"type;;content;;duration(in seconds)\". For example, 0;;success;;3.\r\n"}];
        return;
    }
    int type = [data[0] intValue];
    int duration = [data[2] intValue];
    if (type > 4 || type < 0)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unknown type. The type ranges from 0-3. Please refer to the documentation on Github.\r\n"}];
        return;
    }
    if (duration <= 0)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Duration should be a positive float number.\r\n"}];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (type == 0)
            [Toast hideToast];
        else
            [Toast showToastWithContent:data[1] type:type duration:duration];
    });
}

@implementation Toast
{
    int duration;
    UIColor *backgroundColor;
    int type; // 0 hide 1 error 2 warning 3 message 4 success
}

+ (void) hideToast
{
    if (_window != NULL)
    {
        _window.hidden = YES;
        _window = nil;
    }
}

+ (void) showToastWithContent:(NSString*)content type:(int)type duration:(float)duration
{
    __block UIWindow* currentWindow = NULL;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_window != NULL)
        {
            _window.hidden = YES;
            _window = nil;
        }
        CGFloat screenWidth = [Screen getScreenWidth];
        CGFloat screenHeight = [Screen getScreenHeight];

        CGFloat scale = [Screen getScale];

        UIFont * font = [UIFont systemFontOfSize:(int)(0.015*screenWidth) weight:UIFontWeightLight];
        CGSize contentSize = [content sizeWithFont:font];

        windowWidth = contentSize.width + 40;
        windowHeight = contentSize.height;
        //windowHeight = (int)((screenHeight/scale)/4);

        int windowLeftTopCornerX = (int)((screenWidth/scale)/2 - windowWidth/2);
        int windowLeftTopCornerY = 20;
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(windowLeftTopCornerX, windowLeftTopCornerY, windowWidth, windowHeight)];
        currentWindow = _window;
        _window.windowLevel = UIWindowLevelStatusBar;
        [_window setBackgroundColor: backgroundColorDict[[@(type) stringValue]]];

        _window.layer.borderColor = [UIColor clearColor].CGColor;
        _window.layer.borderWidth = 2.0f;
        _window.layer.cornerRadius = 10;

        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(windowWidth/2 - contentSize.width/2, 0, contentSize.width, contentSize.height)];
        contentLabel.font = font;
        contentLabel.text = content;
        contentLabel.numberOfLines = 1;
        contentLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        contentLabel.adjustsFontSizeToFitWidth = YES;
        contentLabel.adjustsLetterSpacingToFitWidth = YES;
        contentLabel.minimumScaleFactor = 10.0f/12.0f;
        contentLabel.clipsToBounds = YES;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = fontColorDict[[@(type) stringValue]];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        [_window addSubview:contentLabel];

        _window.hidden = NO;

    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:duration];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (currentWindow != _window)
            {
                return;
            }
            _window.hidden = YES;
            _window = nil;
        });
    });
    
}

- (void) show {

    
}

- (void) setContent:(NSString*)content {
    self.content = content;
}

- (void) setBackgroundColor:(UIColor*)color{

}

- (void) setDuration:(int)d {
    duration = d;
}






@end