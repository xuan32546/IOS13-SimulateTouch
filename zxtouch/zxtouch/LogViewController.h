//
//  LogViewController.h
//  zxtouch
//
//  Created by Jason on 2021/1/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)doneButtonClick:(id)sender;
- (IBAction)clearButtonClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
