//
//  InsertTextIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "InsertTextIntentHandler.h"

@implementation InsertTextIntentHandler

@synthesize springBoardSocket;

- (nonnull id)initWithSocketInstance:(nonnull Socket *)springBoardSocket { 
    self = [super init];
    if (self)
    {
        self.springBoardSocket = springBoardSocket;
    }
    return self;
}

- (void)handleInsertText:(nonnull InsertTextIntent *)intent completion:(nonnull void (^)(InsertTextIntentResponse * _Nonnull))completion { 
    InsertTextIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[@(1), intent.text];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_TEXT_INPUT data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[InsertTextIntentResponse alloc] initWithCode:InsertTextIntentResponseCodeSuccess userActivity:nil];

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
        response = [[InsertTextIntentResponse alloc] initWithCode:InsertTextIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveTextForInsertText:(nonnull InsertTextIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion { 
    INStringResolutionResult *result;
    
    if (intent.text)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.text];
    }
    else
    {
        result = INStringResolutionResult.unsupported;
    }
        
    completion(result);
}

@end
