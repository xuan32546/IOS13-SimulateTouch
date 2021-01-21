//
//  TableViewCellWithSwitch.m
//  zxtouch
//
//  Created by Jason on 2021/1/20.
//

#import "TableViewCellWithSwitch.h"

@implementation TableViewCellWithSwitch

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitleText:(NSString *)title {
    self.title.text = title;
}



- (void)setBtnInitStatus:(BOOL)status {
    [_switchBtn setOn:status animated:NO];
}




@end

