#import "Window.h"
#import <UIKit/UIKit.h>

// This is a base class
@implementation Window
{
    UIWindow *_window;

}

- (id) initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _window = [[UIWindow alloc] initWithFrame:frame];
    }
    return self;
}

- (void) setUserInteractionEnabled:(BOOL)isEnable {
    [_window setUserInteractionEnabled:isEnable];
}

- (void)setBorderWidth:(CGFloat)aBorderWidth
{
    _window.layer.borderWidth = aBorderWidth;
}

- (void)setCornerRadius:(CGFloat)aCornerRadius
{
    _window.layer.cornerRadius = 10.0f;
}

- (void)setBoarderColor:(UIColor*)color {
    _window.layer.borderColor = color.CGColor;
}

-(void) test{
    NSLog(@"com.zjx.springboard: window test");
}

@end
