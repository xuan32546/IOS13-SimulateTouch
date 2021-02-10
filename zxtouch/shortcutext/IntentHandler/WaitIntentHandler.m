//
//  WaitIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/10.
//

#import "WaitIntentHandler.h"

@implementation WaitIntentHandler

@synthesize springBoardSocket;

- (void)handleWait:(nonnull WaitIntent *)intent completion:(nonnull void (^)(WaitIntentResponse * _Nonnull))completion {
    [NSThread sleepForTimeInterval:[intent.seconds doubleValue]];
    WaitIntentResponse *response = [[WaitIntentResponse alloc] initWithCode:WaitIntentResponseCodeSuccess userActivity:nil];
    completion(response);
}

- (void)resolveSecondsForWait:(nonnull WaitIntent *)intent withCompletion:(nonnull void (^)(WaitSecondsResolutionResult * _Nonnull))completion {
    WaitSecondsResolutionResult *result;
    double seconds = [intent.seconds doubleValue];
    if (seconds < 0)
    {
        result = WaitSecondsResolutionResult.unsupported;
    }
    else
    {
        result = [WaitSecondsResolutionResult successWithResolvedValue:seconds];
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
