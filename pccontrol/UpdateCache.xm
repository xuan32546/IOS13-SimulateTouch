#include "UpdateCache.h"
#include "Common.h"

#define UPDATE_POPUP_WINDOW_VOLUMN_DOWN_OPEN_FROM_CONFIG 1

extern BOOL openPopUpByDoubleVolumnDown;

void updateCacheFromRawData(UInt8* eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];

    int type = [data[0] intValue];

    if (type == UPDATE_POPUP_WINDOW_VOLUMN_DOWN_OPEN_FROM_CONFIG)
    {
        NSString *configFilePath = getCommonConfigFilePath();

        NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];

        if (config[@"double_click_volume_show_popup"])
        {
            openPopUpByDoubleVolumnDown = [config[@"double_click_volume_show_popup"] boolValue];
        }
    }
    else
    {
        NSLog(@"com.zjx.springboard: unknown task type for updating cache.");
    }
}