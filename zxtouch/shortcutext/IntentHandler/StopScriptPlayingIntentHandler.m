//
//  StopScriptPlayingIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "StopScriptPlayingIntentHandler.h"

@implementation StopScriptPlayingIntentHandler

@synthesize springBoardSocket;

- (void)handleStopScriptPlaying:(nonnull StopScriptPlayingIntent *)intent completion:(nonnull void (^)(StopScriptPlayingIntentResponse * _Nonnull))completion {
    StopScriptPlayingIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_PLAY_SCRIPT_FORCE_STOP data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[StopScriptPlayingIntentResponse alloc] initWithCode:StopScriptPlayingIntentResponseCodeSuccess userActivity:nil];

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
        response = [[StopScriptPlayingIntentResponse alloc] initWithCode:StopScriptPlayingIntentResponseCodeFailure userActivity:nil];
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
