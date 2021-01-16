#import "Popup.h"
#import "Screen.h"
#import "Record.h"
#include "AlertBox.h"
#import <UIKit/UIKit.h>

extern CGFloat device_screen_width;
extern CGFloat device_screen_height;
extern CFRunLoopRef recordRunLoop;

static int windowWidth = 250;
static int windowHeight = 250;

@implementation PopupWindow
{
    UIWindow *_window;
    BOOL isShown;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat screenWidth = [Screen getScreenWidth];
            CGFloat screenHeight = [Screen getScreenHeight];

            CGFloat scale = [Screen getScale];

            windowWidth = (int)((screenWidth/scale)/1.7);
            //windowHeight = (int)((screenHeight/scale)/4);

            int windowLeftTopCornerX = (int)((screenWidth/scale)/2 - windowWidth/2);
            int windowLeftTopCornerY = 0;
            _window = [[UIWindow alloc] initWithFrame:CGRectMake(windowLeftTopCornerX, windowLeftTopCornerY, windowWidth, windowHeight)];
            _window.windowLevel = UIWindowLevelStatusBar;
            [_window setBackgroundColor:[UIColor whiteColor]];

            _window.layer.borderColor = [UIColor whiteColor].CGColor;
            _window.layer.borderWidth = 2.0f;
            _window.layer.cornerRadius = 15.0f;

            // Add header
            NSString *headerText = @"ZXTouch Panel";

            UIFont * font = [UIFont systemFontOfSize:30];
            CGSize headerSize = [headerText sizeWithFont:font];

            UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(windowWidth/2 - headerSize.width/2, 0, headerSize.width, headerSize.height)];
            headerLabel.font = font;
            headerLabel.text = headerText;
            headerLabel.numberOfLines = 1;
            headerLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
            headerLabel.adjustsFontSizeToFitWidth = YES;
            headerLabel.adjustsLetterSpacingToFitWidth = YES;
            headerLabel.minimumScaleFactor = 10.0f/12.0f;
            headerLabel.clipsToBounds = YES;
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.textColor = [UIColor blackColor];
            headerLabel.textAlignment = NSTextAlignmentLeft;
            [_window addSubview:headerLabel];

            // Add hide button
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton addTarget:self 
                    action:@selector(hide)
            forControlEvents:UIControlEventTouchUpInside];
            [closeButton setTitle:@"X" forState:UIControlStateNormal];
                        closeButton.layer.borderColor = [UIColor blueColor].CGColor;
            closeButton.layer.borderWidth = 2.0f;
            closeButton.layer.cornerRadius = 10.0f;

            [closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
 
            closeButton.backgroundColor = [UIColor clearColor];

            closeButton.frame = CGRectMake(windowWidth-25, 5, 20, 20);
            [_window addSubview:closeButton];

            // row 2 buttons
            // add record button
            UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [recordButton addTarget:self 
                    action:@selector(recordingStart)
            forControlEvents:UIControlEventTouchUpInside];

            recordButton.backgroundColor = [UIColor clearColor];
            [recordButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/zxtouch/start-recording.png"] forState:UIControlStateNormal];

            recordButton.frame = CGRectMake(30, headerSize.height + 10, 50, 50);
            [_window addSubview:recordButton];
        });
        isShown = NO;        
    }
    return self;
}

- (void) recordingStart {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self hide];
        NSError *err = nil;
        startRecording(0, &err);
        if (err)
        {
            showAlertBox(@"Error", [NSString stringWithFormat:@"Unable to start recording. Reason: %@",[err localizedDescription]], 999);
            return;
        }
        recordRunLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}

- (void) show {
    dispatch_async(dispatch_get_main_queue(), ^{
        _window.hidden = NO;
    });
    isShown = YES;
}

- (void) hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        _window.hidden = YES;
    });
    isShown = NO;
}

- (BOOL) isShown {
    return isShown;
}
@end
