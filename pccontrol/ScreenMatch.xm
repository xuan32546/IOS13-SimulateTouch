#include "ScreenMatch.h"
#include "TemplateMatch.h"
#include "Screen.h"

CGRect screenMatchFromRawData(UInt8 *eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];
    NSString *templatePath = data[0];
    int maxTryTimes = 2;
    float acceptableValue = 0.8;
    float scaleRation = 0.8;
    if ([data count] == 4)
    {
        maxTryTimes = [data[1] intValue];
        acceptableValue = [data[2] floatValue];
        scaleRation = [data[3] floatValue];
    }
    else if ([data count] != 1)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;The data format should be \"template_path[;;max_try_times;;acceptable_value;;scaleRation]\"\r\n"}];
        return CGRect();
    }
    return [ScreenMatch matchCurrentScreenWithTemplate:templatePath maxTryTimes:maxTryTimes acceptableValue:acceptableValue scaleRation:scaleRation error:error];
}

@implementation ScreenMatch

+ (CGRect)matchCurrentScreenWithTemplate:(NSString*)templatePath maxTryTimes:(int)mtt acceptableValue:(float)av scaleRation:(float)sr error:(NSError**)err {
    if (![[NSFileManager defaultManager] fileExistsAtPath:templatePath])
    {
        *err = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Template image not found for image matching. Template path: %@\r\n", templatePath]}];
        return CGRect();
    }
    TemplateMatch *templateMatch = [[TemplateMatch alloc] init];
    [templateMatch setAcceptableValue:av];
    [templateMatch setMaxTryTimes:mtt];
    [templateMatch setScaleRation:sr];
    CGImageRef screen = [Screen createScreenShotCGImageRef];
    if (!screen)
    {
        *err = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Error happens when template matching. Screenshot is nil.\r\n"}];
        NSLog(@"com.zjx.springboard: -1;;Error happens when template matching. Screenshot is nil.\r\n");
        return CGRect();
    }

    CGRect result = [templateMatch templateMatchWithCGImage:screen templatePath:templatePath error:err];
    CGImageRelease(screen);
    return result;
}


@end