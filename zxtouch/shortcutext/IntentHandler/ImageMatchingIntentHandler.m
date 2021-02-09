//
//  ImageMatchingIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "ImageMatchingIntentHandler.h"

@implementation ImageMatchingIntentHandler

@synthesize springBoardSocket;

- (void)handleImageMatching:(nonnull ImageMatchingIntent *)intent completion:(nonnull void (^)(ImageMatchingIntentResponse * _Nonnull))completion {
    ImageMatchingIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[intent.templateImagePath, intent.maxTryTimes, intent.acceptableValue, intent.scaleRation];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_TEMPLATE_MATCH data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[ImageMatchingIntentResponse alloc] initWithCode:ImageMatchingIntentResponseCodeSuccess userActivity:nil];

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
        response = [[ImageMatchingIntentResponse alloc] initWithCode:ImageMatchingIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveAcceptableValueForImageMatching:(nonnull ImageMatchingIntent *)intent withCompletion:(nonnull void (^)(ImageMatchingAcceptableValueResolutionResult * _Nonnull))completion {
    ImageMatchingAcceptableValueResolutionResult *result;
    double acceptableValue = [intent.acceptableValue doubleValue];
    if (acceptableValue < 0.1 || acceptableValue > 1)
    {
        result = ImageMatchingAcceptableValueResolutionResult.unsupported;
    }
    else
    {
        result = [ImageMatchingAcceptableValueResolutionResult successWithResolvedValue:acceptableValue];
    }
    
    completion(result);
}

- (void)resolveMaxTryTimesForImageMatching:(nonnull ImageMatchingIntent *)intent withCompletion:(nonnull void (^)(ImageMatchingMaxTryTimesResolutionResult * _Nonnull))completion {
    ImageMatchingMaxTryTimesResolutionResult *result;
    int maxTryTimes = [intent.maxTryTimes intValue];
    if (maxTryTimes < 1)
    {
        result = ImageMatchingMaxTryTimesResolutionResult.unsupported;
    }
    else
    {
        result = [ImageMatchingMaxTryTimesResolutionResult successWithResolvedValue:maxTryTimes];
    }
    
    completion(result);
}

- (void)resolveScaleRationForImageMatching:(nonnull ImageMatchingIntent *)intent withCompletion:(nonnull void (^)(ImageMatchingScaleRationResolutionResult * _Nonnull))completion {
    ImageMatchingScaleRationResolutionResult *result;
    double scaleRation = [intent.scaleRation doubleValue];
    if (scaleRation < 0.1 || scaleRation >= 1)
    {
        result = ImageMatchingScaleRationResolutionResult.unsupported;
    }
    else
    {
        result = [ImageMatchingScaleRationResolutionResult successWithResolvedValue:scaleRation];
    }
    
    completion(result);
}

- (void)resolveTemplateImagePathForImageMatching:(nonnull ImageMatchingIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.templateImagePath)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.templateImagePath];
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
