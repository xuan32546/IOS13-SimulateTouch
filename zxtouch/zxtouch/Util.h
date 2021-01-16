//
//  Util.h
//  zxtouch
//
//  Created by Jason on 2021/1/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject
+ (void)showAlertBoxWithOneOption:(UIViewController*)vc title:(NSString*)aTitle message:(NSString*)aMessage buttonString:(NSString*)aBts;
@end

NS_ASSUME_NONNULL_END
