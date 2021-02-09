//
//  PerformTouchIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import "PerformTouchIntentHandler.h"


@implementation PerformTouchIntentHandler
@synthesize springBoardSocket;


- (void)handlePerformTouch:(nonnull PerformTouchIntent *)intent completion:(nonnull void (^)(PerformTouchIntentResponse * _Nonnull))completion {
    PerformTouchIntentResponse *response;
    
    if (self.springBoardSocket)
    {
        NSArray *dataArray = @[[NSString stringWithFormat:@"1%d%02d%05d%05d", (int)intent.type-1, [intent.touchIndex intValue], (int)([intent.x doubleValue]*10), (int)([intent.y doubleValue]*10)]];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_PERFORM_TOUCH data:dataArray]];
        response = [[PerformTouchIntentResponse alloc] initWithCode:PerformTouchIntentResponseCodeSuccess userActivity:nil];
    }
    else
    {
        response = [[PerformTouchIntentResponse alloc] initWithCode:PerformTouchIntentResponseCodeFailure userActivity:nil];
    }
     

    completion(response);
}

- (void)resolveTouchIndexForPerformTouch:(nonnull PerformTouchIntent *)intent withCompletion:(nonnull void (^)(PerformTouchTouchIndexResolutionResult * _Nonnull))completion {
    PerformTouchTouchIndexResolutionResult *result;
    result = [PerformTouchTouchIndexResolutionResult successWithResolvedValue:[intent.touchIndex longValue]];
    
    completion(result);
}

- (void)resolveTypeForPerformTouch:(nonnull PerformTouchIntent *)intent withCompletion:(nonnull void (^)(TouchTypeResolutionResult * _Nonnull))completion {
    TouchTypeResolutionResult *result;
    if (intent.type - 1 < 0 || intent.type - 1 >= 3)
    {
        result = TouchTypeResolutionResult.unsupported;
    }
    else
    {
        result = [TouchTypeResolutionResult successWithResolvedTouchType:(long)intent.type];
    }
    
    completion(result);
}

- (void)resolveXForPerformTouch:(nonnull PerformTouchIntent *)intent withCompletion:(nonnull void (^)(PerformTouchXResolutionResult * _Nonnull))completion {
    PerformTouchXResolutionResult *result;
    result = [PerformTouchXResolutionResult successWithResolvedValue:[intent.x doubleValue]];
    
    completion(result);
}

- (void)resolveYForPerformTouch:(nonnull PerformTouchIntent *)intent withCompletion:(nonnull void (^)(PerformTouchYResolutionResult * _Nonnull))completion {
    PerformTouchYResolutionResult *result;
    result = [PerformTouchYResolutionResult successWithResolvedValue:[intent.y doubleValue]];
    
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
