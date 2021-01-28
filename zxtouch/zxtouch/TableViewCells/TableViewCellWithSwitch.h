//
//  TableViewCellWithSwitch.h
//  zxtouch
//
//  Created by Jason on 2021/1/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCellWithSwitch : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;


- (void)setTitleText:(NSString *)title;
- (void)setBtnInitStatus:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
