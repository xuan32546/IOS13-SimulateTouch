//
//  ActivatorConfigurationViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/29.
//

#import "ActivatorConfigurationViewController.h"
#import "TableViewCellWithEntry.h"
#import "libactivator.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "Config.h"
#import "Util.h"
#import "PlaySettingsNavigationController.h"
#import "ZXTouchActivatorTaskTypes.h"
#import "ActivatorEventsTableViewController.h"


@interface ActivatorConfigurationViewController ()

@end

@implementation ActivatorConfigurationViewController
{
    NSMutableDictionary* table;
    NSMutableArray *eventNames;
    NSMutableDictionary *config;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self refreshPage];
    
    UINib *entryCellNib = [UINib nibWithNibName:@"TableViewCellWithEntry" bundle:nil];
    [_tableView registerNib:entryCellNib forCellReuseIdentifier:@"entryCell"];
    
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)refreshPage {
    Class ac = objc_getClass("LAActivator");
        
    if (ac)
    {
        table = [[NSMutableDictionary alloc] init];
        eventNames = [[NSMutableArray alloc] init];
        
        
        config = [[NSMutableDictionary alloc] initWithContentsOfFile:ACTIVATOR_CONFIG_PATH];
        if (!config)
            config = [[NSMutableDictionary alloc] init];

        
        LAActivator* activator = [ac sharedInstance];
        NSArray *registeredEvents = [activator eventsAssignedToListenerWithName:@"com.zjx.zxtouch"];
        for (LAEvent* event in registeredEvents)
        {
            NSString *eventName = event.name;
            NSString *groupName = [activator localizedGroupForEventName:eventName];
            NSString *localizedTitle = [activator localizedTitleForEventName:eventName];
            //NSString *localizedDescription = [activator localizedDescriptionForEventName:eventName];
            
            BOOL isAdded = false;
            // search in event names
            for (NSString* i in eventNames)
            {
                if ([i isEqualToString:eventName])
                {
                    isAdded = true;
                    break;
                }
            }
            if (isAdded)
                continue;
            
            [eventNames addObject:eventName];
            
            NSMutableArray *groupEvents = [table objectForKey:groupName];
            
            NSMutableDictionary *eventConfig = config[eventName];

            int eventType = [eventConfig[@"type"] intValue];
            
            NSString *eventToPerform = NSLocalizedString(@"unassigned", nil);
            if (eventType == AUTORUN)
            {
                eventToPerform = NSLocalizedString(@"runScript", nil);
            }
            else if (eventType == SHOW_POPUP)
            {
                eventToPerform = NSLocalizedString(@"showPopup", nil);
            }
            else if (eventType == STOP_PLAYING_ALL)
            {
                eventToPerform = NSLocalizedString(@"stopScriptPlay", nil);
            }
            if (groupEvents == nil)
            {
                [table setObject:[[NSMutableArray alloc] initWithObjects:@{@"title": localizedTitle, @"eventString": eventToPerform, @"event_name": eventName}, nil] forKey:groupName];
            }
            else
            {
                [groupEvents addObject:@{@"title": localizedTitle, @"eventString": eventToPerform, @"event_name": eventName}];
            }
        }
    }
    [self.tableView reloadData];
    
    if ([[table allKeys] count] == 0)
    {
        [Util showAlertBoxWithOneOption:self title:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"pleaseAssignEvents", nil) buttonString:@"OK"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refreshPage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [table[[table allKeys][section]] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[table allKeys] count];
}

//每行显示什么东西
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"entryCell";

    TableViewCellWithEntry *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    //判断队列里面是否有这个cell 没有自己创建，有直接使用
    if (cell == nil) {
        //没有,创建一个
        cell = [[TableViewCellWithEntry alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    [cell.title setText:table[[table allKeys][indexPath.section]][indexPath.row][@"title"]];
    [cell.subTitle setText:table[[table allKeys][indexPath.section]][indexPath.row][@"eventString"]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *resultView = [[UIView alloc] init];
    //view.backgroundColor = [UIColor greenColor];
    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.font = [UIFont systemFontOfSize:13];
    title.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];

    title.text = [table allKeys][section];

    
    [resultView addSubview:title];
    
    [[title.leftAnchor constraintEqualToAnchor:resultView.leftAnchor constant:10] setActive:YES];
    [[title.bottomAnchor constraintEqualToAnchor:resultView.bottomAnchor constant:-5] setActive:YES];

    return resultView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingPages" bundle:nil];
    ActivatorEventsTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ActivatorEventsTableViewController"];
    vc.eventName = table[[table allKeys][indexPath.section]][indexPath.row][@"event_name"];
    vc.config = config;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
