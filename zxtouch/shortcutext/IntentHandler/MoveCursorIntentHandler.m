//
//  MoveCursorIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "MoveCursorIntentHandler.h"

@implementation MoveCursorIntentHandler

@synthesize springBoardSocket;

- (nonnull id)initWithSocketInstance:(nonnull Socket *)springBoardSocket {
    self = [super init];
    if (self)
    {
        self.springBoardSocket = springBoardSocket;
    }
    return self;
}

- (void)handleMoveCursor:(nonnull MoveCursorIntent *)intent completion:(nonnull void (^)(MoveCursorIntentResponse * _Nonnull))completion { 
    MoveCursorIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[@(3), intent.offset];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_TEXT_INPUT data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[MoveCursorIntentResponse alloc] initWithCode:MoveCursorIntentResponseCodeSuccess userActivity:nil];

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
        response = [[MoveCursorIntentResponse alloc] initWithCode:MoveCursorIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveOffsetForMoveCursor:(nonnull MoveCursorIntent *)intent withCompletion:(nonnull void (^)(MoveCursorOffsetResolutionResult * _Nonnull))completion {
    MoveCursorOffsetResolutionResult *result;
    int offset = [intent.offset intValue];

    result = [MoveCursorOffsetResolutionResult successWithResolvedValue:offset];
    
    completion(result);
}

@end
