//
//  PlaySettingsTableViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import "PlaySettingsViewController.h"
#import "TableViewCellWithInput.h"
#import "TableViewCellWithEntry.h"
#import "PlaySettingsNavigationController.h"
#import "ScriptPlaySettingsActivatorViewController.h"
#import "Config.h"
#import "Util.h"

#import "libactivator.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface PlaySettingsViewController ()
{
    NSMutableDictionary *currentConfiguration;
}

@end

@implementation PlaySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = NSLocalizedString(@"playSettings", nil);
    
    
    UINib *inputCellNib = [UINib nibWithNibName:@"TableViewCellWithInput" bundle:nil];
    [_tableView registerNib:inputCellNib forCellReuseIdentifier:@"InputCell"];
    
    UINib *entryCellNib = [UINib nibWithNibName:@"TableViewCellWithEntry" bundle:nil];
    [_tableView registerNib:entryCellNib forCellReuseIdentifier:@"EntryCell"];
    
    NSMutableDictionary *config;

    if ([[NSFileManager defaultManager] fileExistsAtPath:SCRIPT_PLAY_CONFIG_PATH])
    {
        config = [[NSMutableDictionary alloc] initWithContentsOfFile:SCRIPT_PLAY_CONFIG_PATH];
    }
    else
    {
        config = [[NSMutableDictionary alloc] init];
    }
    
    
    NSMutableDictionary *individualConfigs = [config valueForKey:@"individual_configs"];
    if (individualConfigs == nil)
    {
        individualConfigs = [[NSMutableDictionary alloc] init];
    }
    
    currentConfiguration = individualConfigs[((PlaySettingsNavigationController*)self.navigationController).path];
    
    if (!currentConfiguration)
    {
        currentConfiguration = [NSMutableDictionary new];
        
        [currentConfiguration setObject:@"0"
                  forKey:@"repeat_times"];
        [currentConfiguration setObject:@"0"
                  forKey:@"interval"];
        [currentConfiguration setObject:@"1.0"
                  forKey:@"speed"];
    }
}

- (BOOL)isInt:(NSString*)str {
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    BOOL isInt = [scan scanInt:&val] && [scan isAtEnd];

    return isInt;
}


- (BOOL)isFloat:(NSString*)str {
    NSScanner* scan = [NSScanner scannerWithString:str];
    float val;
    BOOL isFLoat = [scan scanFloat:&val] && [scan isAtEnd];

    
    return isFLoat;
}

- (void)intervalInputChanged:(id)sender {
    UITextField *input = (UITextField*)sender;

    currentConfiguration[@"interval"] = input.text;
}

- (void)speedInputChanged:(id)sender {
    UITextField *input = (UITextField*)sender;

    currentConfiguration[@"speed"] = input.text;
}

- (void)repeatTimeInputChanged:(id)sender {
    UITextField *input = (UITextField*)sender;

    currentConfiguration[@"repeat_times"] = input.text;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *result;


    if (indexPath.row == 0)
    {
        static NSString *cellID = @"InputCell";

        TableViewCellWithInput *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            cell = [[TableViewCellWithInput alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        //[cell setButtonText:@"Rename"];
        [cell.title setText:NSLocalizedString(@"repeatTime", nil)];

        [cell.input setText:currentConfiguration[@"repeat_times"]];

        [cell.input addTarget:self
                      action:@selector(repeatTimeInputChanged:)
             forControlEvents:UIControlEventEditingChanged];
        
        result = cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *cellID = @"InputCell";

        TableViewCellWithInput *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            cell = [[TableViewCellWithInput alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        [cell.title setText:NSLocalizedString(@"interval", nil)];
        
        [cell.input setText:currentConfiguration[@"interval"]];
        [cell.input addTarget:self
                      action:@selector(intervalInputChanged:)
             forControlEvents:UIControlEventEditingChanged];
        
        result = cell;
    }
    else if (indexPath.row == 2)
    {
        static NSString *cellID = @"InputCell";

        TableViewCellWithInput *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            cell = [[TableViewCellWithInput alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        [cell.title setText:NSLocalizedString(@"speed", nil)];
        
        [cell.input setText:currentConfiguration[@"speed"]];
        [cell.input addTarget:self
                      action:@selector(speedInputChanged:)
             forControlEvents:UIControlEventEditingChanged];
        
        result = cell;
    }
    else if (indexPath.row == 3)
    {
        static NSString *cellID = @"EntryCell";

        TableViewCellWithEntry *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        [cell.title setText:@"Activator"];
        [cell.subTitle setText:@">"];

        result = cell;
    }
    
    return result;
}

- (void)saveTriggerForScript {
    //PlaySettingsNavigationController *nc = (PlaySettingsNavigationController *)self.navigationController;
        
    

     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3)
    {
        dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
        Class la = objc_getClass("LAActivator");
        if (la)
        {
            ScriptPlaySettingsActivatorViewController *vc = [[ScriptPlaySettingsActivatorViewController alloc] init];
            vc.title = @"Set Trigger For Script";
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [Util showAlertBoxWithOneOption:self title:@"Error" message:NSLocalizedString(@"activatorNeedInstall", nil) buttonString:@"OK"];
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonClicked:(id)sender {
    NSMutableDictionary *config;
    // write to config file
    if ([[NSFileManager defaultManager] fileExistsAtPath:SCRIPT_PLAY_CONFIG_PATH])
    {
        config = [[NSMutableDictionary alloc] initWithContentsOfFile:SCRIPT_PLAY_CONFIG_PATH];
    }
    else
    {
        config = [[NSMutableDictionary alloc] init];
    }
    
    
    NSMutableDictionary *individualConfigs = [config valueForKey:@"individual_configs"];
    if (individualConfigs == nil)
    {
        individualConfigs = [[NSMutableDictionary alloc] init];
    }

    
    TableViewCellWithInput *repeatTimesCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    TableViewCellWithInput *intervalCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    TableViewCellWithInput *speedCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    if (![self isInt:repeatTimesCell.input.text] || ![self isFloat:intervalCell.input.text] || ![self isFloat:speedCell.input.text])
    {
        [Util showAlertBoxWithOneOption:self title:@"Error" message:@"Please input integer for repeat times and float for interval and speed" buttonString:@"OK"];
        return;
    }
    
    
    individualConfigs[((PlaySettingsNavigationController*)self.navigationController).path] = currentConfiguration;

    config[@"individual_configs"] = individualConfigs;
    [config writeToFile:SCRIPT_PLAY_CONFIG_PATH atomically:NO];
    // read indicator color from the config file
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
