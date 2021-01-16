//
//  LogViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/16.
//

#import "LogViewController.h"
#include "Config.h"

@interface LogViewController ()

@end

@implementation LogViewController
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refrshTextView];
}

- (void)refrshTextView
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:RUNTIME_OUTPUT_PATH])
    {
        _textView.text = @"";
        return;
    }
    
    NSError *err = nil;
    NSString* content = [NSString stringWithContentsOfFile:RUNTIME_OUTPUT_PATH
                                                  encoding:NSUTF8StringEncoding
                                                     error:&err];
    if (err)
    {
        NSLog(@"Error while reading log file. Error: %@", err);
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                       message:[NSString stringWithFormat:@"Error while reading log file. Error message: %@", err]
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    _textView.text = content;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clearButtonClick:(id)sender {
    if (![[NSFileManager defaultManager] fileExistsAtPath:RUNTIME_OUTPUT_PATH])
    {
        return;
    }
    
    NSError *err = nil;

    [[NSFileManager defaultManager] removeItemAtPath:RUNTIME_OUTPUT_PATH error:&err];
    
    if (err)
    {
        NSLog(@"Error while clearing log. Error: %@", err);
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                       message:[NSString stringWithFormat:@"Error while clearing log. Error message: %@", err]
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self refrshTextView];
}


- (IBAction)doneButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
