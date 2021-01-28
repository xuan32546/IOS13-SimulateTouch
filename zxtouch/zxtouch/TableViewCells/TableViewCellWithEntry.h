//
//  TableViewCellWithEntry.h
//  zxtouch
//
//  Created by Jason on 2021/1/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCellWithEntry : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) NSString *clickHandler;

@end

NS_ASSUME_NONNULL_END
