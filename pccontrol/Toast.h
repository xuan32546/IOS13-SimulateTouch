#ifndef TOAST_H
#define TOAST_H

#endif
void showToastFromRawData(UInt8 *eventData, NSError **error);

@interface Toast : NSObject
+ (void) showToastWithContent:(NSString*)content type:(int)type duration:(float)duration position:(int)position fontSize:(int)afontSize; // positon: 0 top 1 bottom 2 left(not supported) 3 right (ns)
+ (void) hideToast;
- (void) show;
- (void) setContent:(NSString*)content;
- (void) setBackgroundColor:(UIColor*)color;
- (void) setDuration:(int)d;

@end