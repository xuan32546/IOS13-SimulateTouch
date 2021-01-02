//
//  FolderContentViewController.h
//  zxtouch
//
//  Created by Jason on 2020/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FolderContentViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (void) setFolder:(NSString*)folder;

@end

NS_ASSUME_NONNULL_END
