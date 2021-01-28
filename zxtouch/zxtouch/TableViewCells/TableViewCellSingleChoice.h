//
//  TableViewCellSingleChoice.h
//  zxtouch
//
//  Created by Jason on 2021/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCellSingleChoice : UITableViewCell
@property (assign, nonatomic) BOOL check;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;

@end

NS_ASSUME_NONNULL_END
