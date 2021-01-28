//
//  TableViewCellWithSlider.m
//  zxtouch
//
//  Created by Jason on 2021/1/20.
//

#import "TableViewCellWithSlider.h"

@implementation TableViewCellWithSlider

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _value.text = [NSString stringWithFormat:@"%.1f", _slideBar.value];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)slideBarChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    
    _value.text = [NSString stringWithFormat:@"%.1f", slider.value];
}
@end
