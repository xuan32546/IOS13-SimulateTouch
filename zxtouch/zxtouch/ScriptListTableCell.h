//
//  ScriptListTableCell.h
//  zxtouch
//
//  Created by Jason on 2020/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScriptListTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *scriptTitle;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) UIViewController* parentViewController;

- (void) setTitle:(NSString*)title;
- (void) setPropertyWithPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
