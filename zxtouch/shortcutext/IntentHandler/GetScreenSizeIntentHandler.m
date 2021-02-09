//
//  GetScreenSizeIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "GetScreenSizeIntentHandler.h"

@implementation GetScreenSizeIntentHandler

@synthesize springBoardSocket;

- (nonnull id)initWithSocketInstance:(nonnull Socket *)springBoardSocket {
    self = [super init];
    if (self)
    {
        self.springBoardSocket = springBoardSocket;
    }
    return self;
}

- (void)handleGetScreenSize:(nonnull GetScreenSizeIntent *)intent completion:(nonnull void (^)(GetScreenSizeIntentResponse * _Nonnull))completion {
    GetScreenSizeIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[@(1)];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_GET_DEVICE_INFO data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[GetScreenSizeIntentResponse alloc] initWithCode:GetScreenSizeIntentResponseCodeSuccess userActivity:nil];

        NSArray* returnDataArr = [[returnData substringToIndex:returnData.length - 2] componentsSeparatedByString:@";;"];
        

        
        BOOL success = NO;
        int width = -1, height = -1;
        
        if ([returnDataArr[0] isEqualToString:@"0"])
        {
            success = YES;
            if ([returnDataArr count] < 3)
            {
                response = [[GetScreenSizeIntentResponse alloc] initWithCode:GetScreenSizeIntentResponseCodeFailure userActivity:nil];
                response.error = @"Unknown error happens, the return array length is less than 3.";
                completion(response);
                return;
            }
            width = [returnDataArr[1] intValue];
            height = [returnDataArr[2] intValue];
        }
        else
        {
            success = NO;
        }
        
        
        response.result = [[IntentSize alloc] initWithIdentifier:@"com.zjx.zxtouch.shortcutext.types.task-result" displayString:NSLocalizedFormatString(@"IntentSizeResultDisplayString", success, width, height)];
        
        response.result.success = @(success);
        response.result.width = @(width);
        response.result.height = @(height);
        
        response.result.success = @(NO);
        
        NSUInteger count = [returnDataArr count];
        response.result.info = [returnDataArr subarrayWithRange:NSMakeRange(1, count-1)];
    }
    else
    {
        response = [[GetScreenSizeIntentResponse alloc] initWithCode:GetScreenSizeIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

@end
