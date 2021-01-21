//
//  SettingsPageViewController.h
//  zxtouch
//
//  Created by Jason on 2021/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsPageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

NS_ASSUME_NONNULL_END
