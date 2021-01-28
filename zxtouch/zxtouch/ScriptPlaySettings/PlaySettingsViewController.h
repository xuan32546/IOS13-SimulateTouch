//
//  PlaySettingsTableViewController.h
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlaySettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
