//
//  RunShellCommandIntentHandler.h
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import <Foundation/Foundation.h>
#import <Intents/Intents.h>
#import "Socket.h"
#import "SocketDataHandler.h"
#import "SpringBoardSocketClient.h"
#import "../Task.h"

#import "RunShellCommandIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface RunShellCommandIntentHandler : NSObject<RunShellCommandIntentHandling,SpringBoardSocketClient>

@end

NS_ASSUME_NONNULL_END
