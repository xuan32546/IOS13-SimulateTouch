//
//  SettingsPageViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/18.
//

#import "SettingsPageViewController.h"
#import "ScriptListTableCell.h"
#import "TouchIndicatorConfigurationViewController.h"
#import "Util.h"

#import "TableViewCellWithSwitch.h"
#import "TableViewCellWithSlider.h"
#import "TableViewCellWithEntry.h"

#define SETTING_CELL_SWITCH 0
#define SETTING_CELL_ENTRY 1


@interface SettingsPageViewController ()

@end

@implementation SettingsPageViewController
{
    NSArray *sections;
    NSArray<NSArray*> *cellsForEachSection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    sections = @[NSLocalizedString(@"remoteManagement", nil), NSLocalizedString(@"control", nil)]; // , @"HELP"
    
    // [@{"type": ?, @"title": ?, @"content": ?, ... more depends on the cell type}]
    //
    cellsForEachSection = @[
        @[
            @{@"type": @(SETTING_CELL_SWITCH), @"title": NSLocalizedString(@"webServer", nil), @"switch_click_handler": NSStringFromSelector(@selector(handleWebServerWithSwitchCellInstance:)), @"switch_init_status": @(NO)}
        ],
        @[
            @{@"type": @(SETTING_CELL_ENTRY), @"title": @"Activator", @"secondary_title": @"", @"row_click_handler": NSStringFromSelector(@selector(handleActivatorWithEntryCellInstance:))},
            @{@"type": @(SETTING_CELL_ENTRY), @"title": NSLocalizedString(@"touchIndicator", nil), @"secondary_title": @"", @"row_click_handler": NSStringFromSelector(@selector(handleTouchIndicatorWithEntryCellInstance:))}
        ]
    ];
     
    UINib *SwitchCellNib = [UINib nibWithNibName:@"TableViewCellWithSwitch" bundle:nil];
    [_tableView registerNib:SwitchCellNib forCellReuseIdentifier:@"SwitchCell"];

    UINib *entryCellNib = [UINib nibWithNibName:@"TableViewCellWithEntry" bundle:nil];
    [_tableView registerNib:entryCellNib forCellReuseIdentifier:@"EntryCell"];
    
}

- (void)handleWebServerWithSwitchCellInstance:(UISwitch*)s {
    if ([s isOn])
    {
        NSLog(@"Start WebServer");
        [Util showAlertBoxWithOneOption:self title:@"ZXTouch" message:NSLocalizedString(@"webServerCommingSoon", nil) buttonString:@"OK"];
        [s setOn:NO];
    }
    else
    {
        NSLog(@"Stop WebServer");
    }
}

- (void)handleActivatorWithEntryCellInstance:(TableViewCellWithEntry*)cell {
    if ([cell isSelected])
    {
        NSLog(@"Selected");
    }
    else
    {
        NSLog(@"Deselected");
    }
}

- (void)handleTouchIndicatorWithEntryCellInstance:(TableViewCellWithEntry*)cell {
    if ([cell isSelected])
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingPages" bundle:nil];
        TouchIndicatorConfigurationViewController *touchIndicatorConfigurationViewController = [sb instantiateViewControllerWithIdentifier:@"TouchIndicatorConfigurationPage"];
        [self.navigationController pushViewController:touchIndicatorConfigurationViewController animated:YES];
        //[self.navigationController setTitle:@"Touch Indicator"];
    }

}


//配置每个section(段）有多少row（行） cell
//默认只有一个section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return cellsForEachSection[section].count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

//每行显示什么东西
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *result;
    

    NSInteger indexInCurrentSection = indexPath.row;

    
    NSArray* cellList = cellsForEachSection[indexPath.section];

    NSDictionary *cellInfo = cellList[indexInCurrentSection];
    if ([cellInfo[@"type"] intValue] == SETTING_CELL_SWITCH)
    {
        static NSString *cellID = @"SwitchCell";

        TableViewCellWithSwitch *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            cell = [[TableViewCellWithSwitch alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.title.text = cellInfo[@"title"];
        [cell.switchBtn addTarget:self action:NSSelectorFromString(cellInfo[@"switch_click_handler"]) forControlEvents:UIControlEventValueChanged];
        [cell.switchBtn setOn:[cellInfo[@"switch_init_status"] boolValue]];
        
        result = cell;
    }
    else if ([cellInfo[@"type"] intValue] == SETTING_CELL_ENTRY)
    {
        static NSString *cellID = @"EntryCell";

        TableViewCellWithEntry *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            NSLog(@"create a setting cell switch");
            cell = [[TableViewCellWithEntry alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.title.text = cellInfo[@"title"];
        cell.subTitle.text = cellInfo[@"secondary_title"];
        cell.clickHandler = cellInfo[@"row_click_handler"];
        
        result = cell;
    }
    
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[TableViewCellWithEntry class]])
    {
        TableViewCellWithEntry *entry = (TableViewCellWithEntry*)cell;
        [self performSelector:NSSelectorFromString(entry.clickHandler) withObject:entry];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *resultView = [[UIView alloc] init];
    //view.backgroundColor = [UIColor greenColor];
    
    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.font = [UIFont boldSystemFontOfSize:13];
    title.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];

    title.text = sections[section];

    
    [resultView addSubview:title];
    
    [[title.centerYAnchor constraintEqualToAnchor:resultView.centerYAnchor] setActive:YES];
    [[title.leftAnchor constraintEqualToAnchor:resultView.leftAnchor constant:10] setActive:YES];
    
    return resultView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
