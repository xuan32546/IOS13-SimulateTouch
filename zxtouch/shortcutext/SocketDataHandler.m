//
//  SocketDataHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/8.
//

#import "SocketDataHandler.h"

@implementation SocketDataHandler

+ (NSString*)formatSocketData:(int)taskType data:(NSArray*)dataArray {
    return [NSString stringWithFormat:@"%2d%@\r\n", taskType, [dataArray componentsJoinedByString:@";;"]];
}

@end
