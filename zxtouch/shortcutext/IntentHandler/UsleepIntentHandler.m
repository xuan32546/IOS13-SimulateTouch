//
//  UsleepIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/10.
//

#import "UsleepIntentHandler.h"

@implementation UsleepIntentHandler

@synthesize springBoardSocket;

- (void)handleUsleep:(nonnull UsleepIntent *)intent completion:(nonnull void (^)(UsleepIntentResponse * _Nonnull))completion {
    usleep([intent.microseconds intValue]);
    UsleepIntentResponse *response = [[UsleepIntentResponse alloc] initWithCode:UsleepIntentResponseCodeSuccess userActivity:nil];
    completion(response);
}

- (void)resolveMicrosecondsForUsleep:(nonnull UsleepIntent *)intent withCompletion:(nonnull void (^)(UsleepMicrosecondsResolutionResult * _Nonnull))completion {
    UsleepMicrosecondsResolutionResult *result;
    int microseconds = [intent.microseconds intValue];
    if (microseconds < 0)
    {
        result = UsleepMicrosecondsResolutionResult.unsupported;
    }
    else
    {
        result = [UsleepMicrosecondsResolutionResult successWithResolvedValue:microseconds];
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
