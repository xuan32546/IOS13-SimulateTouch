//
//  PerformTouchIntentHandler.h
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import <Foundation/Foundation.h>
#import <Intents/Intents.h>
#import "Socket.h"
#import "../SocketDataHandler.h"
#import "SpringBoardSocketClient.h"
#import "../Task.h"

#import "PerformTouchIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PerformTouchIntentHandler : NSObject<PerformTouchIntentHandling, SpringBoardSocketClient>

@end

NS_ASSUME_NONNULL_END
