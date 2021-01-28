//
//  TableViewCellSingleChoice.m
//  zxtouch
//
//  Created by Jason on 2021/1/28.
//

#import "TableViewCellSingleChoice.h"

@implementation TableViewCellSingleChoice


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    if (self.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        _check = false;
    }
    else if (self.accessoryType == UITableViewCellAccessoryNone)
    {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        _check = true;
    }
}

- (void)setCheck:(BOOL)check
{
    if (!check)
    {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        _check = false;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        _check = true;
    }
}
@end
