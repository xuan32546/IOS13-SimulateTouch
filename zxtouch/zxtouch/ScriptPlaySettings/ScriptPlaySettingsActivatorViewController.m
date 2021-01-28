//
//  ScriptPlaySettingsActivatorViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/27.
//

#import "ScriptPlaySettingsActivatorViewController.h"
#import "TableViewCellSingleChoice.h"
#import "libactivator.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "Config.h"
#import "Util.h"
#import "PlaySettingsNavigationController.h"

@interface ScriptPlaySettingsActivatorViewController ()

@end

@implementation ScriptPlaySettingsActivatorViewController
{
    NSMutableDictionary* table;
    NSMutableArray *eventNames;
    NSMutableDictionary *config;
    NSMutableDictionary* autorunDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    Class ac = objc_getClass("LAActivator");
        
    if (ac)
    {
        table = [[NSMutableDictionary alloc] init];
        eventNames = [[NSMutableArray alloc] init];
        
        
        config = [[NSMutableDictionary alloc] initWithContentsOfFile:ACTIVATOR_CONFIG_PATH];
        
        if (!config)
        {
            config = [[NSMutableDictionary alloc] init];
            autorunDict = [[NSMutableDictionary alloc] init];
            [config setObject:autorunDict forKey:@"autorun"];
        }
        else
        {
            autorunDict = [config objectForKey:@"autorun"];
            if (!autorunDict)
            {
                autorunDict = [[NSMutableDictionary alloc] init];
            }
        }
        
        LAActivator* activator = [ac sharedInstance];
        NSArray *registeredEvents = [activator eventsAssignedToListenerWithName:@"com.zjx.zxtouch"];
        for (LAEvent* event in registeredEvents)
        {
            NSString *eventName = event.name;
            NSString *groupName = [activator localizedGroupForEventName:eventName];
            NSString *localizedTitle = [activator localizedTitleForEventName:eventName];
            NSString *localizedDescription = [activator localizedDescriptionForEventName:eventName];
            
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
            
            NSString* pathForEvent = (NSString*)autorunDict[eventName];
            BOOL check = false;
            if (pathForEvent != nil && [pathForEvent isEqualToString:((PlaySettingsNavigationController *)self.navigationController).path])
            {
                check = true;
            }
                
            if (groupEvents == nil)
            {

                [table setObject:[[NSMutableArray alloc] initWithObjects:@{@"title": localizedTitle, @"description": localizedDescription, @"event_name": eventName, @"check":[NSNumber numberWithBool:check]}, nil] forKey:groupName];
            }
            else
            {
                [groupEvents addObject:@{@"title": localizedTitle, @"description": localizedDescription, @"event_name": eventName, @"check":[NSNumber numberWithBool:check]}];
            }
        }
    }
    

    UINib *singleChoiceCellNib = [UINib nibWithNibName:@"TableViewCellSingleChoice" bundle:nil];
    [_tableView registerNib:singleChoiceCellNib forCellReuseIdentifier:@"singleChoiceCell"];
    _tableView.backgroundColor = [UIColor colorWithRed:243/255.0f green:242/255.0f blue:248/255.0f alpha:1.0f];
    _tableView.tableFooterView = [[UIView alloc] init];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//配置每个section(段）有多少row（行） cell
//默认只有一个section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [table[[table allKeys][section]] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[table allKeys] count];
}

//每行显示什么东西
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"singleChoiceCell";

    TableViewCellSingleChoice *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    //判断队列里面是否有这个cell 没有自己创建，有直接使用
    if (cell == nil) {
        //没有,创建一个
        cell = [[TableViewCellSingleChoice alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    [cell.title setText:table[[table allKeys][indexPath.section]][indexPath.row][@"title"]];
    [cell.subtitle setText:table[[table allKeys][indexPath.section]][indexPath.row][@"description"]];
    [cell setCheck:[table[[table allKeys][indexPath.section]][indexPath.row][@"check"] boolValue]];

    
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TableViewCellSingleChoice* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell.check)
    {
        // checked
        PlaySettingsNavigationController *layer = (PlaySettingsNavigationController *)self.navigationController;
        [autorunDict setObject:[layer.path stringByStandardizingPath] forKey:table[[table allKeys][indexPath.section]][indexPath.row][@"event_name"]];
    }
    else
    {
        // unchecked
        [autorunDict setObject:@"" forKey:table[[table allKeys][indexPath.section]][indexPath.row][@"event_name"]];
    }
    
    [config writeToFile:ACTIVATOR_CONFIG_PATH atomically:NO];
}

@end
