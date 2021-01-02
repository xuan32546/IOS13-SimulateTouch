//
//  ScriptListViewController.h
//  zxtouch
//
//  Created by Jason on 2020/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScriptListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *_scriptListTableView;

- (void) setFolder:(NSString*)folder;


@end

NS_ASSUME_NONNULL_END
