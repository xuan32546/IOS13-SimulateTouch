#ifndef SCREEN_H
#define SCREEN_H

@interface Screen :NSObject
{
    
}

+ (void)setScreenSize:(CGFloat)x height:(CGFloat) y;
+ (int)getScreenOrientation;
+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;
+ (CGFloat)getScale;

@end

#endif
