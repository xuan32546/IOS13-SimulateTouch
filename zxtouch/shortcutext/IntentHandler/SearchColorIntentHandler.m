//
//  SearchColorIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "SearchColorIntentHandler.h"

@implementation SearchColorIntentHandler

@synthesize springBoardSocket;

- (nonnull id)initWithSocketInstance:(nonnull Socket *)springBoardSocket {
    self = [super init];
    if (self)
    {
        self.springBoardSocket = springBoardSocket;
    }
    return self;
}

- (void)handleSearchColor:(nonnull SearchColorIntent *)intent completion:(nonnull void (^)(SearchColorIntentResponse * _Nonnull))completion {
    SearchColorIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[@(1), intent.x, intent.y, intent.width, intent.height, intent.redMin, intent.redMax, intent.greenMin, intent.greenMax, intent.blueMin, intent.blueMax, intent.pixelSkip];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_COLOR_SEARCHER data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[SearchColorIntentResponse alloc] initWithCode:SearchColorIntentResponseCodeSuccess userActivity:nil];

        NSArray* returnDataArr = [[returnData substringToIndex:returnData.length - 2] componentsSeparatedByString:@";;"];
        

        
        BOOL success = NO;
        int red = -1, green = -1, blue = -1, x = -1, y = -1;
        
        if ([returnDataArr[0] isEqualToString:@"0"])
        {
            success = YES;
            if ([returnDataArr count] < 6)
            {
                response = [[SearchColorIntentResponse alloc] initWithCode:SearchColorIntentResponseCodeFailure userActivity:nil];
                response.error = @"Unknown error happens, the return array length is less than 6.";
                completion(response);
                return;
            }
            x = [returnDataArr[1] intValue];
            y = [returnDataArr[2] intValue];
            red = [returnDataArr[3] intValue];
            green = [returnDataArr[4] intValue];
            blue = [returnDataArr[5] intValue];
        }
        else
        {
            success = NO;
        }
        
        
        response.result = [[RGBXY alloc] initWithIdentifier:@"com.zjx.zxtouch.shortcutext.types.task-result" displayString:NSLocalizedFormatString(@"RGBResultDisplayString", success, x, y, red, green, blue)];
        
        response.result.success = @(success);
        response.result.x = @(x);
        response.result.y = @(y);
        response.result.red = @(red);
        response.result.green = @(green);
        response.result.blue = @(blue);
        
        response.result.success = @(NO);
        
        NSUInteger count = [returnDataArr count];
        response.result.info = [returnDataArr subarrayWithRange:NSMakeRange(1, count-1)];
    }
    else
    {
        response = [[SearchColorIntentResponse alloc] initWithCode:SearchColorIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

- (void)resolveBlueMaxForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorBlueMaxResolutionResult * _Nonnull))completion {
    SearchColorBlueMaxResolutionResult *result;
    int bm = [intent.blueMax intValue];
    if (bm < 0 || bm > 999999)
    {
        result = SearchColorBlueMaxResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorBlueMaxResolutionResult successWithResolvedValue:bm];
    }
    
    completion(result);
}

- (void)resolveBlueMinForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorBlueMinResolutionResult * _Nonnull))completion {
    SearchColorBlueMinResolutionResult *result;
    int bm = [intent.blueMin intValue];
    if (bm < 0 || bm > 999999)
    {
        result = SearchColorBlueMinResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorBlueMinResolutionResult successWithResolvedValue:bm];
    }
    
    completion(result);
}

- (void)resolveGreenMaxForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorGreenMaxResolutionResult * _Nonnull))completion {
    SearchColorGreenMaxResolutionResult *result;
    int gm = [intent.greenMax intValue];
    if (gm < 0 || gm > 999999)
    {
        result = SearchColorGreenMaxResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorGreenMaxResolutionResult successWithResolvedValue:gm];
    }
    
    completion(result);
}

- (void)resolveGreenMinForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorGreenMinResolutionResult * _Nonnull))completion {
    SearchColorGreenMinResolutionResult *result;
    int gm = [intent.greenMin intValue];
    if (gm < 0 || gm > 999999)
    {
        result = SearchColorGreenMinResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorGreenMinResolutionResult successWithResolvedValue:gm];
    }
    
    completion(result);
}

- (void)resolveHeightForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorHeightResolutionResult * _Nonnull))completion {
    SearchColorHeightResolutionResult *result;
    int height = [intent.height intValue];
    if (height < 0 || height > 999999)
    {
        result = SearchColorHeightResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorHeightResolutionResult successWithResolvedValue:height];
    }
    
    completion(result);
}

- (void)resolvePixelSkipForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorPixelSkipResolutionResult * _Nonnull))completion {
    SearchColorPixelSkipResolutionResult *result;
    int ps = [intent.pixelSkip intValue];
    if (ps < 0 || ps > 999999)
    {
        result = SearchColorPixelSkipResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorPixelSkipResolutionResult successWithResolvedValue:ps];
    }
    
    completion(result);
}

- (void)resolveRedMaxForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorRedMaxResolutionResult * _Nonnull))completion {
    SearchColorRedMaxResolutionResult *result;
    int rm = [intent.redMax intValue];
    if (rm < 0 || rm > 999999)
    {
        result = SearchColorRedMaxResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorRedMaxResolutionResult successWithResolvedValue:rm];
    }
    
    completion(result);
}

- (void)resolveRedMinForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorRedMinResolutionResult * _Nonnull))completion {
    SearchColorRedMinResolutionResult *result;
    int rm = [intent.redMin intValue];
    if (rm < 0 || rm > 999999)
    {
        result = SearchColorRedMinResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorRedMinResolutionResult successWithResolvedValue:rm];
    }
    
    completion(result);
}

- (void)resolveWidthForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorWidthResolutionResult * _Nonnull))completion {
    SearchColorWidthResolutionResult *result;
    int width = [intent.width intValue];
    if (width < 0 || width > 999999)
    {
        result = SearchColorWidthResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorWidthResolutionResult successWithResolvedValue:width];
    }
    
    completion(result);
}

- (void)resolveXForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorXResolutionResult * _Nonnull))completion {
    SearchColorXResolutionResult *result;
    int x = [intent.x intValue];
    if (x < 0 || x > 999999)
    {
        result = SearchColorXResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorXResolutionResult successWithResolvedValue:x];
    }
    
    completion(result);
}

- (void)resolveYForSearchColor:(nonnull SearchColorIntent *)intent withCompletion:(nonnull void (^)(SearchColorYResolutionResult * _Nonnull))completion {
    SearchColorYResolutionResult *result;
    int y = [intent.y intValue];
    if (y < 0 || y > 999999)
    {
        result = SearchColorYResolutionResult.unsupported;
    }
    else
    {
        result = [SearchColorYResolutionResult successWithResolvedValue:y];
    }
    
    completion(result);
}

@end
