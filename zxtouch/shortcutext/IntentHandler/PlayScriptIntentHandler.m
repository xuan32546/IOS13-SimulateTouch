//
//  PlayScriptIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "PlayScriptIntentHandler.h"

@implementation PlayScriptIntentHandler

@synthesize springBoardSocket;

- (void)handlePlayScript:(nonnull PlayScriptIntent *)intent completion:(nonnull void (^)(PlayScriptIntentResponse * _Nonnull))completion {
    PlayScriptIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[intent.scriptAbsolutePath];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_PLAY_SCRIPT data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[PlayScriptIntentResponse alloc] initWithCode:PlayScriptIntentResponseCodeSuccess userActivity:nil];

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
        response = [[PlayScriptIntentResponse alloc] initWithCode:PlayScriptIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveScriptAbsolutePathForPlayScript:(nonnull PlayScriptIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.scriptAbsolutePath)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.scriptAbsolutePath];
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
