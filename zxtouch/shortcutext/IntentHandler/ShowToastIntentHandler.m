//
//  ShowToastIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "ShowToastIntentHandler.h"

@implementation ShowToastIntentHandler

@synthesize springBoardSocket;

- (void)handleShowToast:(nonnull ShowToastIntent *)intent completion:(nonnull void (^)(ShowToastIntentResponse * _Nonnull))completion {
    ShowToastIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[@(intent.toastType-1), intent.message, intent.duration, @(intent.position-1), intent.fontSize];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_SHOW_TOAST data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[ShowToastIntentResponse alloc] initWithCode:ShowToastIntentResponseCodeSuccess userActivity:nil];

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
        response = [[ShowToastIntentResponse alloc] initWithCode:ShowToastIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveDurationForShowToast:(nonnull ShowToastIntent *)intent withCompletion:(nonnull void (^)(ShowToastDurationResolutionResult * _Nonnull))completion {
    ShowToastDurationResolutionResult *result;
    double duration = [intent.duration doubleValue];
    if (duration < 0)
    {
        result = ShowToastDurationResolutionResult.unsupported;
    }
    else
    {
        result = [ShowToastDurationResolutionResult successWithResolvedValue:duration];
    }
    
    completion(result);
}

- (void)resolveFontSizeForShowToast:(nonnull ShowToastIntent *)intent withCompletion:(nonnull void (^)(ShowToastFontSizeResolutionResult * _Nonnull))completion { 
    ShowToastFontSizeResolutionResult *result;
    int fontSize = [intent.fontSize intValue];
    if (fontSize < 0 || fontSize > 50)
    {
        result = ShowToastFontSizeResolutionResult.unsupported;
    }
    else
    {
        result = [ShowToastFontSizeResolutionResult successWithResolvedValue:fontSize];
    }
    
    completion(result);
}

- (void)resolveMessageForShowToast:(nonnull ShowToastIntent *)intent withCompletion:(nonnull void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result;
    
    if (intent.message)
    {
        result = [INStringResolutionResult successWithResolvedString:intent.message];
    }
    else
    {
        result = INStringResolutionResult.unsupported;
    }
        
    completion(result);
}

- (void)resolveToastTypeForShowToast:(nonnull ShowToastIntent *)intent withCompletion:(nonnull void (^)(ToastTypeResolutionResult * _Nonnull))completion {
    ToastTypeResolutionResult *result;
    if (intent.toastType - 1 < 0 || intent.toastType - 1 > 4)
    {
        result = ToastTypeResolutionResult.unsupported;
    }
    else
    {
        result = [ToastTypeResolutionResult successWithResolvedToastType:(long)intent.toastType];
    }
    
    completion(result);
}

- (void)resolvePositionForShowToast:(nonnull ShowToastIntent *)intent withCompletion:(nonnull void (^)(ToastPositionResolutionResult * _Nonnull))completion {
    ToastPositionResolutionResult *result;
    if (intent.position - 1 < 0 || intent.position - 1 > 4)
    {
        result = ToastPositionResolutionResult.unsupported;
    }
    else
    {
        result = [ToastPositionResolutionResult successWithResolvedToastPosition:(long)intent.position];
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
