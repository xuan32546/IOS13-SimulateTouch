#ifndef TOAST_H
#define TOAST_H

#endif
void showToastFromRawData(UInt8 *eventData, NSError **error);

@interface Toast : NSObject
+ (void) showToastWithContent:(NSString*)content type:(int)type duration:(float)duration;
+ (void) hideToast;
- (void) show;
- (void) setContent:(NSString*)content;
- (void) setBackgroundColor:(UIColor*)color;
- (void) setDuration:(int)d;

@end