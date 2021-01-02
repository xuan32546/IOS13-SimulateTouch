//
//  FolderContentViewController.m
//  zxtouch
//
//  Created by Jason on 2020/12/15.
//

#import "FolderContentViewController.h"
#import "ScriptListTableCell.h"

@interface FolderContentViewController ()

@end

@implementation FolderContentViewController
{
    NSString *currentFolder;
    NSMutableArray *scriptList;
}

- (NSMutableArray*) updateScriptList {
    NSMutableArray *scriptList = [[NSMutableArray alloc] init];

    NSError *err = nil;

    
    NSArray* recordings = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentFolder error:&err];
    
    if (err)
    {
        NSLog(@"Error happens while getting recording list in springboard document folder: %@", err);
    }
    BOOL isDir = NO;
    
    for (NSString *scriptName in recordings)
    {
        
        NSString *path = [NSString stringWithFormat:@"%@/%@", currentFolder, scriptName];
        if (![[scriptName pathExtension] isEqualToString:@"bdl"] && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [scriptList insertObject:path atIndex:0];
        }
        else
        {
            [scriptList addObject:path];
        }
    }
    
    // add scripts from documents list
    
    return scriptList;
}

- (void) setFolder:(NSString*)folder {
    currentFolder = folder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    scriptList = [self updateScriptList];
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
    
    //[cell setTitle:[scriptList[indexPath.row] lastPathComponent]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *scriptBundleContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"scriptBundleContent"];
    [self.navigationController pushViewController:scriptBundleContentViewController animated:YES];
    
    scriptBundleContentViewController.title = @"folder";
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
