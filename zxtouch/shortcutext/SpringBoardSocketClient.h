//
//  SpringBoardSocketClient.h
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import <Foundation/Foundation.h>
#import "Socket.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpringBoardSocketClient <NSObject>

@property (weak, nonatomic) Socket *springBoardSocket;


- (id)initWithSocketInstance:(Socket*)springBoardSocket;

@end

NS_ASSUME_NONNULL_END
