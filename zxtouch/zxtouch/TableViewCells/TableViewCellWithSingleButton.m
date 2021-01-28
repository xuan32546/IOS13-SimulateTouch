//
//  TableViewCellWithSingleButton.m
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import "TableViewCellWithSingleButton.h"

@implementation TableViewCellWithSingleButton

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setButtonText:(NSString*)text {
    [_button setTitle:text forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
