#ifndef POPUP_H
#define POPUP_H

@interface PopupWindow : NSObject
- (void) show;
- (void) hide;

- (BOOL) isShown;
@end

#endif