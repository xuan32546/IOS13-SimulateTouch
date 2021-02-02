//
//  ActivatorEventsTableViewController.h
//  zxtouch
//
//  Created by Jason on 2021/1/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActivatorEventsTableViewController : UITableViewController

@property (strong, nonatomic) NSString *eventName;
@property (weak, nonatomic) NSMutableDictionary *config;

@end

NS_ASSUME_NONNULL_END
