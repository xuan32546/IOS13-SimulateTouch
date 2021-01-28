//
//  MoreOptionsTableViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/24.
//

#import "MoreOptionsPopOverTableViewController.h"
#import "TableViewCellWithSingleButton.h"
#import "Util.h"
#import "PlaySettingsViewController.h"
#import "PlaySettingsNavigationController.h"

@interface MoreOptionsPopOverTableViewController ()
{
    NSString *currentFolder;
    ScriptListViewController* upperLevel;
    
}

@end

@implementation MoreOptionsPopOverTableViewController
@synthesize tableView;

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UINib *entryCellNib = [UINib nibWithNibName:@"TableViewCellWithSingleButton" bundle:nil];
    [tableView registerNib:entryCellNib forCellReuseIdentifier:@"SingleButtonCell"];
    
    int rows = [self tableView:tableView numberOfRowsInSection:0];
    self.preferredContentSize = CGSizeMake(300, rows*50);
    
    NSLog(@"script folder: %@", currentFolder);
}

- (void)changeName:(id)sender {
    if (!self->currentFolder)
    {
        [Util showAlertBoxWithOneOption:self title:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"createFolderPathNotSet", nil) buttonString:@"OK"];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Folder Name"
                                                                    message:@"Please enter the folder name"
                                                             preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       if (alert.textFields.count > 0) {
                                                           UITextField *textField = [alert.textFields firstObject];
                                                           if ([textField.text length] != 0)
                                                           {

                                                               // create folder
                                                               BOOL isDir;
                                                               NSError *err = nil;
                                                               NSFileManager *fileManager= [NSFileManager defaultManager];
                                                               NSString* extension = [self->currentFolder pathExtension];
                                                               NSString* newFolderPath = [[self->currentFolder stringByDeletingLastPathComponent] stringByAppendingPathComponent:[textField.text stringByAppendingPathExtension:extension]];
                                                               if([fileManager fileExistsAtPath:newFolderPath isDirectory:&isDir] && isDir)
                                                               {
                                                                   [Util showAlertBoxWithOneOption:self title:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"createFolderAlreadyExists", nil) buttonString:@"OK"];
                                                               }
                                                               else
                                                               {
                                                                   [fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:&err];
                                                                   if (err)
                                                                   {
                                                                       [Util showAlertBoxWithOneOption:self title:NSLocalizedString(@"error", nil) message:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"createFolderFailed", nil), err] buttonString:@"OK"];
                                                                   }
                                                                   
                                                                   [self moveFromFolder:self->currentFolder to:newFolderPath];
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       [self->upperLevel refreshTable];
                                                                   });
                                                               }
                                                               
                                                           }
                                                           else
                                                           {
                                                               [Util showAlertBoxWithOneOption:self title:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"createFolderEmptyName", nil) buttonString:@"OK"];
                                                           }
                                                       }
                                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];

    [alert addAction:cancel];
    [alert addAction:submit];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //textField.placeholder = @""; // if needs
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changePlaySetting:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingPages" bundle:nil];
    PlaySettingsNavigationController *playSettingsViewController = [sb instantiateViewControllerWithIdentifier:@"PlaySettingsNavigationController"];
    
    [playSettingsViewController setPath:[currentFolder stringByStandardizingPath]];

    [self presentViewController:playSettingsViewController animated:YES completion:nil];
    
}

- (id)initWithFolderPath:(NSString *)path
{
    self = [super initWithNibName:@"MoreOptionsPopOverTableViewController" bundle:nil];
    if (self) {
        currentFolder = path;
    }
    return self;
}

- (void)moveFromFolder:(NSString*)source to:(NSString*)dest {
    NSLog(@"source: %@", source);
    NSString *oldDirectoryPath = source;

    NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:nil];

    NSString *newDirectoryPath = dest;

    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath attributes:nil];

    NSError *error = nil;

    for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
    {

        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];

        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];

        [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];

        if (error) {
            [Util showAlertBoxWithOneOption:self title:@"Error" message:[NSString stringWithFormat:@"Error while moving files. Error: %@",error] buttonString:@"OK"];
            
        }

    }
    [[NSFileManager defaultManager] removeItemAtPath:oldDirectoryPath error:nil];
}

- (void)setUpperLevelViewController:(ScriptListViewController*)vc{
    upperLevel = vc;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[currentFolder pathExtension] isEqualToString:@"bdl"])
    {
        return 2;
    }
    else
    {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"SingleButtonCell";

    TableViewCellWithSingleButton *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    //判断队列里面是否有这个cell 没有自己创建，有直接使用
    if (cell == nil) {
        //没有,创建一个
        NSLog(@"create a setting cell switch");
        cell = [[TableViewCellWithSingleButton alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.button.titleLabel.font = [UIFont systemFontOfSize:21];

    if (indexPath.row == 0)
    {
        [cell setButtonText:NSLocalizedString(@"rename", nil)];
        
        [cell.button addTarget:self
              action:@selector(changeName:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    else if (indexPath.row == 1)
    {
        [cell setButtonText:NSLocalizedString(@"playSettings", nil)];
        
        [cell.button addTarget:self
              action:@selector(changePlaySetting:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

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

@end
