#include "ScreenMatch.h"
#include "TemplateMatch.h"

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

OBJC_EXTERN UIImage *_UICreateScreenUIImage(void);
+ (CGRect)matchCurrentScreenWithTemplate:(NSString*)templatePath maxTryTimes:(int)mtt acceptableValue:(float)av scaleRation:(float)sr error:(NSError**)err {
    UIImage *screenImage = _UICreateScreenUIImage();
     // For debugging purpose
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"screenshot.jpg"];

    // Save image.
    [UIImageJPEGRepresentation(screenImage, 0.7) writeToFile:filePath atomically:true];

    NSLog(@"com.zjx.springboard: image path: %@", filePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:templatePath])
    {
        *err = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Template image not found for image matching. Template path: %@\r\n", templatePath]}];
        return CGRect();
    }
    TemplateMatch *templateMatch = [[TemplateMatch alloc] init];
    [templateMatch setAcceptableValue:av];
    [templateMatch setMaxTryTimes:mtt];
    [templateMatch setScaleRation:sr];
    return [templateMatch templateMatchWithUIImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Documents/screenshot.jpg"] template:[UIImage imageWithContentsOfFile:templatePath]];
}


@end