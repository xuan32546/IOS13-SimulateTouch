//
//  TouchIndicatorConfigurationViewController.h
//  zxtouch
//
//  Created by Jason on 2021/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TouchIndicatorConfigurationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
- (void)switchTouchIndicatorStatus:(id)cell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
