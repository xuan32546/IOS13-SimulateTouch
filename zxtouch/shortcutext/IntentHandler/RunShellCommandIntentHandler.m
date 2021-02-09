//
//  RunShellCommandIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import "RunShellCommandIntentHandler.h"

@implementation RunShellCommandIntentHandler

@synthesize springBoardSocket;

- (void)handleRunShellCommand:(nonnull RunShellCommandIntent *)intent completion:(nonnull void (^)(RunShellCommandIntentResponse * _Nonnull))completion {
    RunShellCommandIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[intent.command];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_RUN_SHELL data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[RunShellCommandIntentResponse alloc] initWithCode:RunShellCommandIntentResponseCodeSuccess userActivity:nil];

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
        response = [[RunShellCommandIntentResponse alloc] initWithCode:RunShellCommandIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveCommandForRunShellCommand:(nonnull RunShellCommandIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.command)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.command];
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
