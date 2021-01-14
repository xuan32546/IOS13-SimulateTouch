#include "UIKeyboard.h"
#import <Foundation/NSDistributedNotificationCenter.h>

void inputTextFromRawData(UInt8 *eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];
    NSString *taskContent = @"";
    if ([data count] < 1)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Please specify the text you want to input.\r\n"}];
        return;
    }
    else if ([data count] == 2)
    {
        taskContent = data[1];
    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zjx.zxtouch.keyboardcontrol" object:NULL userInfo:@{@"task_id": data[0], @"task_content": taskContent} deliverImmediately: true];
}