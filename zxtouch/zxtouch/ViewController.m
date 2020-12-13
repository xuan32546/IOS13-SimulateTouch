//
//  ViewController.m
//  zxtouch
//
//  Created by Jason on 2020/12/10.
//

#import "ViewController.h"
#include <stdio.h>

#import "Socket.h"

@interface ViewController ()

@end

@implementation ViewController

/**
Get document root of springboard
*/
NSString* getDocumentRoot()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [NSString stringWithFormat:@"%@/", [paths objectAtIndex:0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    [NSThread sleepForTimeInterval:3.0f];
    
    Socket *spSocket = [Socket new];
    [spSocket connect:@"127.0.0.1" byPort:6000];
    

    FILE *file = fopen("/private/var/mobile/Containers/Data/Application/5563E280-ED63-4AA2-8A3B-CC97E92AE925/Documents/201210140654.bdl/201210140654.raw", "r");

    //system("killall SpringBoard");
    char buffer[256];
    int taskType;
    int sleepTime;
    
    while (fgets(buffer, sizeof(char)*256, file) != NULL)
    {
        NSLog(@"%s",buffer);

        sscanf(buffer, "%2d%d", &taskType, &sleepTime);
        if (taskType == 18)
        {
            usleep(sleepTime);
        }
        else
        {
            [spSocket sendChar:buffer];
        }
    }
        
    NSLog(@"%@", getDocumentRoot());
     */
    // Do any additional setup after loading the view.

    
    
}


@end
