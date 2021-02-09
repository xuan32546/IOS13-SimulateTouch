//
//  SocketDataHandler.h
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketDataHandler : NSObject

+ (NSString*)formatSocketData:(int)taskType data:(NSArray*)dataArray;

@end

NS_ASSUME_NONNULL_END
