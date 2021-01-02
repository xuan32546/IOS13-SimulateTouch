#ifndef COMMON_H
#define COMMON_H

@interface SpringBoard : UIApplication
-(int)_frontMostAppOrientation;
-(id)_accessibilityFrontMostApplication;
@end


@interface SBApplication : NSObject {
    
}
@property (nonatomic, retain, readonly) NSString *displayIdentifier NS_DEPRECATED_IOS(4_0, 8_0);

@end

int getRandomNumberInt(int min, int max);
float getRandomNumberFloat(float min, float max);
NSString* getDocumentRoot();

#endif