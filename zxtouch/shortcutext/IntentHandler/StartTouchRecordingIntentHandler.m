//
//  StartTouchRecordingIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import "StartTouchRecordingIntentHandler.h"

@implementation StartTouchRecordingIntentHandler

@synthesize springBoardSocket;

- (void)handleStartTouchRecording:(nonnull StartTouchRecordingIntent *)intent completion:(nonnull void (^)(StartTouchRecordingIntentResponse * _Nonnull))completion {
    StartTouchRecordingIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_TOUCH_RECORDING_START data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[StartTouchRecordingIntentResponse alloc] initWithCode:StartTouchRecordingIntentResponseCodeSuccess userActivity:nil];

        NSArray* returnDataArr = [[returnData substringToIndex:returnData.length - 2] componentsSeparatedByString:@";;"];
        
        response.result = [[TaskResult alloc] initWithIdentifier:@"com.zjx.zxtouch.shortcutext.types.task-result" displayString:NSLocalizedString(@"taskResultDisplayString", nil)];
        
        
        if ([returnDataArr[0] isEqualToString:@"0"])
        {
            response.result.success = @(YES);
        }
        else
        {
            response.result.success = @(NO);
        }
        NSUInteger count = [returnDataArr count];
        
        response.result.info = [returnDataArr subarrayWithRange:NSMakeRange(1, count-1)];
    }
    else
    {
        response = [[StartTouchRecordingIntentResponse alloc] initWithCode:StartTouchRecordingIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (nonnull id)initWithSocketInstance:(nonnull Socket *)springBoardSocket {
    self = [super init];
    if (self)
    {
        self.springBoardSocket = springBoardSocket;
    }
    return self;
}

@end
