//
//  ScriptListViewController.m
//  zxtouch
//
//  Created by Jason on 2020/12/14.
//

#import "ScriptListViewController.h"
#import "ScriptListTableCell.h"
#import "ScriptEditorViewController.h"
#import "LogViewController.h"
#import "ScriptAdder/AdderPopOverViewController.h"
#include "Config.h"

@interface ScriptListViewController ()

@end

@implementation ScriptListViewController
{
    NSMutableArray *scriptList;
    NSString *currentFolder;
    UIRefreshControl *refreshControl;
}

- (void) setFolder:(NSString*)folder {
    currentFolder = folder;
}

- (IBAction)logButtonClick:(id)sender {

    LogViewController *logEditorViewController = [[LogViewController alloc] initWithNibName: @"LogViewController" bundle: nil];
    
    logEditorViewController.title = @"Log";
    //[logEditorViewController setFile:RUNTIME_OUTPUT_PATH];

    [self presentViewController:logEditorViewController animated:YES completion:nil];
}

- (IBAction)addButtonClick:(id)sender {
    AdderPopOverViewController *contentVC = [[AdderPopOverViewController alloc] initWithNibName:@"AdderPopOverViewController" bundle:nil];
    contentVC.modalPresentationStyle = UIModalPresentationPopover;
    [contentVC setFolder:currentFolder];
    [contentVC setUpperLevelViewController:self];
    UIPopoverPresentationController *popPC = contentVC.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.barButtonItem = sender;
    [self presentViewController:contentVC animated:YES completion:nil];
}


- (NSMutableArray*) updateScriptList {
    NSMutableArray *scriptList = [[NSMutableArray alloc] init];

    if (!currentFolder)
        currentFolder = SCRIPTS_PATH;

    [self insertFileListIntoArray:scriptList fromPath:currentFolder];

    // add scripts from documents list
    return scriptList;
}

- (BOOL) insertFileListIntoArray:(NSMutableArray*)arr fromPath:(NSString*) path {
    NSError *err = nil;
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
    
    if (err)
    {
        NSLog(@"Error happens while getting files list. Error info: %@", err);
        return NO;
    }
    
    
    BOOL isDir = NO;
    for (NSString *fileName in files)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, fileName];
        if (![[fileName pathExtension] isEqualToString:@"bdl"] && [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && isDir)
        {
            [arr insertObject:filePath atIndex:0];
        }
        else
        {
            [arr addObject:filePath];
        }
    }
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notifyDoubleClickVolumnBtn"])
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"prompt", nil)
                                                                       message:NSLocalizedString(@"showPopUpWindow", nil)
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifyDoubleClickVolumnBtn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ZXTouchAlreadyLaunchedv0.0.6"])
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"newFeatures", nil)
                                                                       message:NSLocalizedString(@"006features", nil)
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ZXTouchAlreadyLaunchedv0.0.6"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    scriptList = [self updateScriptList];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self._scriptListTableView.refreshControl = refreshControl;
    
    if (![currentFolder isEqualToString:SCRIPTS_PATH])
    {
        self.navigationItem.leftBarButtonItems = nil;
    }
}


- (void)refreshTable {
    scriptList = [self updateScriptList];
    [__scriptListTableView reloadData];
    
    [refreshControl endRefreshing];
}


//配置每个section(段）有多少row（行） cell
//默认只有一个section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [scriptList count];
}


//每行显示什么东西
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //给每个cell设置ID号（重复利用时使用）
    static NSString *cellID = @"ScriptCell";

    //从tableView的一个队列里获取一个cell
    ScriptListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    //判断队列里面是否有这个cell 没有自己创建，有直接使用
    if (cell == nil) {
        //没有,创建一个
        cell = [[ScriptListTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    [cell setPropertyWithPath:scriptList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isDir;
    
    NSString *path = scriptList[indexPath.row];
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    if (isDir)
    {
        ScriptListViewController *scriptBundleContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"scriptBundleContent"];
        
        
        
        [scriptBundleContentViewController setFolder:path];
        scriptBundleContentViewController.title = [path lastPathComponent];

        [self.navigationController pushViewController:scriptBundleContentViewController animated:YES];
    }
    else
    {
        ScriptEditorViewController *scriptEditorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"fileContentEditor"];
        
        scriptEditorViewController.title = [path lastPathComponent];
        [scriptEditorViewController setFile:path];
        [self.navigationController pushViewController:scriptEditorViewController animated:YES];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"delete button clicked for index path: %@", indexPath);
        // delete files in NSFileManager
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                       message:@"Are you sure you want to remove this file (folder)?"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {NSError *err = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self->scriptList[indexPath.row] error:&err];

            if (err)
            {
                NSLog(@"Error while removing file. Error: %@", err);
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                               message:[NSString stringWithFormat:@"Error while deleting this file. Error message: %@", err]
                                               preferredStyle:UIAlertControllerStyleAlert];
                 
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction * action) {}];
                 
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            // delete element in our script list array
            [self->scriptList removeObjectAtIndex:indexPath.row];
            // reload table view
            [self._scriptListTableView reloadData];}];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
           handler:nil];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
