#ifndef TOUCH_INDICATOR_H
#define TOUCH_INDICATOR_H


void handleTouchIndicatorTaskWithRawData(UInt8* eventData, NSError **error);
void stopTouchIndicator(NSError **error);
void startTouchIndicator(NSError **error);

@interface TouchIndicatorWindow : NSObject
{

}

- (id)init;
- (void)hideIndicator:(int)index;
- (void)showIndicator:(int)index withX:(int)x andY:(int)y majorRadius:(CGFloat)radius;
- (void)show;
- (void)hide;
- (void)moveIndicator:(int)index x:(CGFloat)x y:(CGFloat)y majorRadius:(CGFloat)radius;
- (void)setIndicatorColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end

#endif