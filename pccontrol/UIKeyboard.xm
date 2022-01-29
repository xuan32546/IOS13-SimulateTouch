#include "UIKeyboard.h"
#import <Foundation/NSDistributedNotificationCenter.h>

#define TASK_GET_TEXT_FROM_CLIPBOARD 6
#define TASK_SAVE_TEXT_TO_CLIPBOARD 7

NSString* inputTextFromRawData(UInt8 *eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithUTF8String:(char*)eventData] componentsSeparatedByString:@";;"];

    NSString *taskContent = @"";
    if ([data count] < 1)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Keyboard related event length error. You have to specify the task id.\r\n"}];
        return nil;
    }
    int taskType = [data[0] intValue];
    if (taskType == TASK_GET_TEXT_FROM_CLIPBOARD)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

        if (!pasteboard.string)
            return @"";

        return pasteboard.string;
    }
    else if (taskType == TASK_SAVE_TEXT_TO_CLIPBOARD)
    {  
        if ([data count] < 2)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Keyboard related event error. You have to specify the content you want to paste to clipboard.\r\n"}];
            return nil;
        }
        
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = data[1];
        return @"";
    }

    // otherwise, send it to appdelegate
    if ([data count] == 2)
    {
        taskContent = data[1];
    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zjx.zxtouch.keyboardcontrol" object:NULL userInfo:@{@"task_id": data[0], @"task_content": taskContent} deliverImmediately: true];
    return @"Successfully notify the appdelegate tweak. But not sure whether it works...";

}