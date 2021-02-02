#ifndef COMMON_H
#define COMMON_H

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


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
NSString* getScriptsFolder();
void swapCGFloat(CGFloat *a, CGFloat *b);
NSString *getConfigFilePath();
NSString *getCommonConfigFilePath();
pid_t system2(const char * command, int * infp, int * outfp);

#endif