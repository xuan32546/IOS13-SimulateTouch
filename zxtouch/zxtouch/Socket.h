//
//  Socket.h
//  zxtouch
//
//  Created by Jason on 2020/12/11.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

NS_ASSUME_NONNULL_BEGIN

@interface Socket : NSObject


-(int) connect: (NSString*) ip byPort:(int) port;
-(void) send: (NSString*)msg;
-(void) sendChar: (char*)msg;

@end

NS_ASSUME_NONNULL_END
