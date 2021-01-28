//
//  TableViewCellWithSingleButton.h
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCellWithSingleButton : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *button;

- (void)setButtonText:(NSString*)text;

@end

NS_ASSUME_NONNULL_END
