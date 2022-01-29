#include "AlertBox.h"
#include "SocketServer.h"

void showAlertBoxFromRawData(UInt8 *eventData, NSError **error)
{
    NSString *alertData = [NSString stringWithUTF8String:(char*)eventData];
    NSArray *alertDataArray = [alertData componentsSeparatedByString:@";;"];
    if ([alertDataArray count] < 3)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to show alert box. The socket format should be title;;content;;duration.\r\n"}];
        return;
    }
    if ([alertDataArray[2] intValue] == 0)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Duration should be a integer that is greater than 0\r\n"}];
        return;
    }
    showAlertBox(alertDataArray[0], alertDataArray[1], [alertDataArray[2] intValue]);
}

void showAlertBox(NSString* title, NSString* content, int dismissTime)
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject: title forKey: (__bridge NSString*)kCFUserNotificationAlertHeaderKey];
    [dict setObject: content forKey: (__bridge NSString*)kCFUserNotificationAlertMessageKey];
    [dict setObject: @"Ok" forKey:(__bridge NSString*)kCFUserNotificationDefaultButtonTitleKey];
    
    SInt32 error = 0;
    CFUserNotificationRef alert = CFUserNotificationCreate(NULL, 0, kCFUserNotificationPlainAlertLevel, &error, (__bridge CFDictionaryRef)dict);

    CFOptionFlags response;
    
     if((error) || (CFUserNotificationReceiveResponse(alert, dismissTime, &response))) {
        NSLog(@"com.zjx.springboard: alert error or no user response after %d seconds for title: %@. Content %@", dismissTime, title, content);
     }
    
    /*
    else if((response & 0x3) == kCFUserNotificationAlternateResponse) {
        NSLog(@"cancel");
    } else if((response & 0x3) == kCFUserNotificationDefaultResponse) {
        NSLog(@"view");
    }
    */

    CFRelease(alert);
}