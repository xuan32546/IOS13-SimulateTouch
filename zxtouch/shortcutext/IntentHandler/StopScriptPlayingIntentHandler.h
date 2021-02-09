//
//  StopScriptPlayingIntentHandler.h
//  shortcutext
//
//  Created by Jason on 2021/2/9.
//

#import <Foundation/Foundation.h>
#import <Intents/Intents.h>
#import "Socket.h"
#import "SocketDataHandler.h"
#import "SpringBoardSocketClient.h"
#import "../Task.h"

#import "StopScriptPlayingIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface StopScriptPlayingIntentHandler : NSObject<StopScriptPlayingIntentHandling,SpringBoardSocketClient>

@end

NS_ASSUME_NONNULL_END
