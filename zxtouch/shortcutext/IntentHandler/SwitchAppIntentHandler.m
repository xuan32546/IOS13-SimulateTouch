//
//  SwitchAppIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import "SwitchAppIntentHandler.h"

@implementation SwitchAppIntentHandler

@synthesize springBoardSocket;

- (void)handleSwitchApp:(nonnull SwitchAppIntent *)intent completion:(nonnull void (^)(SwitchAppIntentResponse * _Nonnull))completion {
    SwitchAppIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {

        NSArray *dataArray = @[intent.bundleIdentifier];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_PROCESS_BRING_FOREGROUND data:dataArray]];

        NSString* returnData = [self.springBoardSocket recv:1024];
        response = [[SwitchAppIntentResponse alloc] initWithCode:SwitchAppIntentResponseCodeSuccess userActivity:nil];
        
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
        response = [[SwitchAppIntentResponse alloc] initWithCode:SwitchAppIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveBundleIdentifierForSwitchApp:(nonnull SwitchAppIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.bundleIdentifier)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.bundleIdentifier];
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


