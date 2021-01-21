//
//  TableViewCellWithSlider.h
//  zxtouch
//
//  Created by Jason on 2021/1/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCellWithSlider : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISlider *slideBar;
@property (weak, nonatomic) IBOutlet UILabel *value;

- (IBAction)slideBarChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
