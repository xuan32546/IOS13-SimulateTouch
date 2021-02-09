//
//  PickColorIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//


#import "PickColorIntentHandler.h"

@implementation PickColorIntentHandler

@synthesize springBoardSocket;

- (void)handlePickColor:(nonnull PickColorIntent *)intent completion:(nonnull void (^)(PickColorIntentResponse * _Nonnull))completion {
    PickColorIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[intent.x, intent.y];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_COLOR_PICKER data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[PickColorIntentResponse alloc] initWithCode:PickColorIntentResponseCodeSuccess userActivity:nil];

        NSArray* returnDataArr = [[returnData substringToIndex:returnData.length - 2] componentsSeparatedByString:@";;"];
        

        
        BOOL success = NO;
        int red = -1, green = -1, blue = -1;
        
        if ([returnDataArr[0] isEqualToString:@"0"])
        {
            success = YES;
            if ([returnDataArr count] < 4)
            {
                response = [[PickColorIntentResponse alloc] initWithCode:PickColorIntentResponseCodeFailure userActivity:nil];
                response.error = @"Unknown error happens, the return array length is less than 4.";
                completion(response);
                return;
            }
            red = [returnDataArr[1] intValue];
            green = [returnDataArr[2] intValue];
            blue = [returnDataArr[3] intValue];
        }
        else
        {
            success = NO;
        }
        
        
        response.result = [[RGB alloc] initWithIdentifier:@"com.zjx.zxtouch.shortcutext.types.task-result" displayString:NSLocalizedFormatString(@"RGBResultDisplayString", success, red, green, blue)];
        
        response.result.success = @(success);
        response.result.red = @(red);
        response.result.green = @(green);
        response.result.blue = @(blue);
        
        response.result.success = @(NO);
        
        NSUInteger count = [returnDataArr count];
        response.result.info = [returnDataArr subarrayWithRange:NSMakeRange(1, count-1)];
    }
    else
    {
        response = [[PickColorIntentResponse alloc] initWithCode:PickColorIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveXForPickColor:(nonnull PickColorIntent *)intent withCompletion:(nonnull void (^)(PickColorXResolutionResult * _Nonnull))completion {
    PickColorXResolutionResult *result;
    double x = [intent.x doubleValue];
    if (x < 0)
    {
        result = PickColorXResolutionResult.unsupported;
    }
    else
    {
        result = [PickColorXResolutionResult successWithResolvedValue:x];
    }
    
    completion(result);
}

- (void)resolveYForPickColor:(nonnull PickColorIntent *)intent withCompletion:(nonnull void (^)(PickColorYResolutionResult * _Nonnull))completion {
    PickColorYResolutionResult *result;
    double y = [intent.y doubleValue];
    if (y < 0)
    {
        result = PickColorYResolutionResult.unsupported;
    }
    else
    {
        result = [PickColorYResolutionResult successWithResolvedValue:y];
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
