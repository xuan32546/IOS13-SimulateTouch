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

- (void) setTitle:(NSString*)title;
- (void) setPropertyWithPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
