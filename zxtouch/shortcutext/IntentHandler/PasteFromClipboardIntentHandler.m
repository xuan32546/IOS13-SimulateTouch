//
//  PasteFromClipboardIntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import "PasteFromClipboardIntentHandler.h"

@implementation PasteFromClipboardIntentHandler

@synthesize springBoardSocket;

- (nonnull id)initWithSocketInstance:(nonnull Socket *)springBoardSocket {
    self = [super init];
    if (self)
    {
        self.springBoardSocket = springBoardSocket;
    }
    return self;
}

- (void)handlePasteFromClipBoard:(nonnull PasteFromClipBoardIntent *)intent completion:(nonnull void (^)(PasteFromClipBoardIntentResponse * _Nonnull))completion {
    PasteFromClipBoardIntentResponse *response;
    if ([self.springBoardSocket isConnected])
    {
        NSArray *dataArray = @[@(5)];
        [self.springBoardSocket send:[SocketDataHandler formatSocketData:TASK_TEXT_INPUT data:dataArray]];
        NSString* returnData = [self.springBoardSocket recv:1024];
        
        response = [[PasteFromClipBoardIntentResponse alloc] initWithCode:PasteFromClipBoardIntentResponseCodeSuccess userActivity:nil];

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
        response = [[PasteFromClipBoardIntentResponse alloc] initWithCode:PasteFromClipBoardIntentResponseCodeFailure userActivity:nil];
        response.error = @"Unable to connect to the springboard";
    }
     
    completion(response);
}

@end
