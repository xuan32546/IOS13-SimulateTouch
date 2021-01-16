//
//  Util.m
//  zxtouch
//
//  Created by Jason on 2021/1/16.
//
#import "Util.h"

@implementation Util


+ (void)showAlertBoxWithOneOption:(UIViewController*)vc title:(NSString*)aTitle message:(NSString*)aMessage buttonString:(NSString*)aBts
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:aTitle
                                                                   message:aMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:aBts style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {}];
     
    [alert addAction:defaultAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

@end
