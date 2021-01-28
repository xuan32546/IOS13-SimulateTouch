//
//  MoreOptionsTableViewController.h
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import <UIKit/UIKit.h>
#import "ScriptListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoreOptionsPopOverTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithFolderPath:(NSString *)path;
- (void)setUpperLevelViewController:(ScriptListViewController*)vc;

@end

NS_ASSUME_NONNULL_END
