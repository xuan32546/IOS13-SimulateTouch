//
//  ScriptEditorViewController.h
//  zxtouch
//
//  Created by Jason on 2020/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScriptEditorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textInput;

- (void) setFile:(NSString*)file;

@end

NS_ASSUME_NONNULL_END
