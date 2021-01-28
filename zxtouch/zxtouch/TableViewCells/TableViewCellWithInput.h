//
//  TableViewCellWithInput.h
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCellWithInput : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextField *input;

@end

NS_ASSUME_NONNULL_END
