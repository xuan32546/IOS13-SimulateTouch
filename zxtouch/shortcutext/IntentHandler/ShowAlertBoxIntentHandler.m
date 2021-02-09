//
//  ShowAlertBoxIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import "ShowAlertBoxIntentHandler.h"

@implementation ShowAlertBoxIntentHandler

@synthesize springBoardSocket;

- (void)handleShowAlertBox:(nonnull ShowAlertBoxIntent *)intent completion:(nonnull void (^)(ShowAlertBoxIntentResponse * _Nonnull))completion {
    ShowAlertBoxIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[intent.title, intent.message, intent.duration];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_SHOW_ALERT_BOX data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[ShowAlertBoxIntentResponse alloc] initWithCode:ShowAlertBoxIntentResponseCodeSuccess userActivity:nil];

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
        response = [[ShowAlertBoxIntentResponse alloc] initWithCode:ShowAlertBoxIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveDurationForShowAlertBox:(nonnull ShowAlertBoxIntent *)intent withCompletion:(nonnull void (^)(ShowAlertBoxDurationResolutionResult * _Nonnull))completion {
    ShowAlertBoxDurationResolutionResult *result;
    int duration = [intent.duration intValue];
    if (duration <= 0 || duration > 1000)
    {
        result = ShowAlertBoxDurationResolutionResult.unsupported;
    }
    else
    {
        result = [ShowAlertBoxDurationResolutionResult successWithResolvedValue:duration];
    }
    
    completion(result);
}

- (void)resolveMessageForShowAlertBox:(nonnull ShowAlertBoxIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.message)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.message];
    }
    else
    {
        result = INStringResolutionResult.unsupported;
    }
        
    completion(result);
}

- (void)resolveTitleForShowAlertBox:(nonnull ShowAlertBoxIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.title)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.title];
    }
    else
    {
        result = INStringResolutionResult.unsupported;
    }
        
    completion(result);
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
