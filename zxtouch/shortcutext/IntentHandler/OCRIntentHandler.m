//
//  OCRIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "OCRIntentHandler.h"

@implementation OCRIntentHandler

@synthesize springBoardSocket;

- (void)handleOCR:(nonnull OCRIntent *)intent completion:(nonnull void (^)(OCRIntentResponse * _Nonnull))completion {
    OCRIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_TEXT_RECOGNIZER data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[OCRIntentResponse alloc] initWithCode:OCRIntentResponseCodeSuccess userActivity:nil];

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
        response = [[OCRIntentResponse alloc] initWithCode:OCRIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveAutoCorrectForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(INBooleanResolutionResult * _Nonnull))completion {
    INBooleanResolutionResult *result;
    
    if (intent.autoCorrect)
    {
        result = [INBooleanResolutionResult successWithResolvedValue:intent.autoCorrect];
    }
    else
    {
        result = INBooleanResolutionResult.unsupported;
    }
        
    completion(result);
}


- (void)resolveDebugImagePathForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.debugImagePath)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.debugImagePath];
    }
    else
    {
        result = INStringResolutionResult.unsupported;
    }
        
    completion(result);
}

- (void)resolveHeightForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(OCRHeightResolutionResult * _Nonnull))completion {
    OCRHeightResolutionResult *result;
    int height = [intent.height intValue];
    if (height < 0 || height > 999999)
    {
        result = OCRHeightResolutionResult.unsupported;
    }
    else
    {
        result = [OCRHeightResolutionResult successWithResolvedValue:height];
    }
    
    completion(result);
}

- (void)resolveModeForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(OCRLevelResolutionResult * _Nonnull))completion {
    OCRLevelResolutionResult *result;
    if (intent.mode - 1 < 0 || intent.mode - 1 > 1)
    {
        result = OCRLevelResolutionResult.unsupported;
    }
    else
    {
        result = [OCRLevelResolutionResult successWithResolvedOCRLevel:(long)intent.mode];
    }
    
    completion(result);
}

- (void)resolveTextMinimumHeightForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(OCRTextMinimumHeightResolutionResult * _Nonnull))completion {
    OCRTextMinimumHeightResolutionResult *result;
    double ps = [intent.textMinimumHeight doubleValue];
    if (ps < 0 || ps > 999999)
    {
        result = OCRTextMinimumHeightResolutionResult.unsupported;
    }
    else
    {
        result = [OCRTextMinimumHeightResolutionResult successWithResolvedValue:ps];
    }
    
    completion(result);
}

- (void)resolveWidthForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(OCRWidthResolutionResult * _Nonnull))completion {
    OCRWidthResolutionResult *result;
    int width = [intent.width intValue];
    if (width < 0 || width > 999999)
    {
        result = OCRWidthResolutionResult.unsupported;
    }
    else
    {
        result = [OCRWidthResolutionResult successWithResolvedValue:width];
    }
    
    completion(result);
}

- (void)resolveXForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(OCRXResolutionResult * _Nonnull))completion {
    OCRXResolutionResult *result;
    int x = [intent.x intValue];
    if (x < 0 || x > 999999)
    {
        result = OCRXResolutionResult.unsupported;
    }
    else
    {
        result = [OCRXResolutionResult successWithResolvedValue:x];
    }
    
    completion(result);
}

- (void)resolveYForOCR:(nonnull OCRIntent *)intent withCompletion:(nonnull void (^)(OCRYResolutionResult * _Nonnull))completion {
    OCRYResolutionResult *result;
    int y = [intent.y intValue];
    if (y < 0 || y > 999999)
    {
        result = OCRYResolutionResult.unsupported;
    }
    else
    {
        result = [OCRYResolutionResult successWithResolvedValue:y];
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
