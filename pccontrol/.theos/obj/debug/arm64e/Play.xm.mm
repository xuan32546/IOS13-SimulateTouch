#line 1 "Play.xm"
#include "Play.h"
#include "SocketServer.h"
#include "Process.h"

BOOL isPlaying = false;
BOOL scriptPlayForceStop = false;
UIWindow *_playIndicator;

int playScript(UInt8* path, CFWriteStreamRef requestClient)
{
    if (isPlaying)
    {
        NSLog(@"com.zjx.springboard: Unable to run the script. Another script is currently running.");
        notifyClient((UInt8*)"-1 Unable to run the script. Another script is currently running.\n\r", requestClient);
        return -1;
    }

    
    NSLog(@"com.zjx.springboard: dictionary path: %@", [NSString stringWithFormat:@"%s/info.plist", path]);

    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%s", path] isDirectory:&isDir] || !isDir)
    {
        NSLog(@"com.zjx.springboard: Unable to run the script. Path not found or it is not a directory.");
        notifyClient((UInt8*)"-1 Unable to run the script. Path not found or it is not a directory.\n\r", requestClient);
        return -1;
    }
    
    NSString *infoFilePath = [NSString stringWithFormat:@"%s/info.plist", path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoFilePath isDirectory:&isDir])
    {
        NSLog(@"com.zjx.springboard: Unable to run the script. Info.plist not found.");
        notifyClient((UInt8*)"-1 Unable to run the script. Info.plist not found.\n\r", requestClient);
        return -1;
    }
    NSDictionary *scriptInfo = [NSDictionary dictionaryWithContentsOfFile:infoFilePath];
    
    NSString *entryFileName = scriptInfo[@"Entry"];
    NSString *fileExtension = [entryFileName pathExtension];

    NSString *foregroundApp = scriptInfo[@"FrontApp"];
    
    if ([fileExtension isEqualToString:@"raw"])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _playIndicator = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];
            _playIndicator.windowLevel = UIWindowLevelStatusBar;
            _playIndicator.hidden = NO;
            [_playIndicator setBackgroundColor:[UIColor clearColor]];

            UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];

            
            circleView.layer.cornerRadius = 10;  
            circleView.backgroundColor = [UIColor greenColor];
            [_playIndicator addSubview:circleView];
        });

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            playFromRawFile([NSString stringWithFormat:@"%s/%@", path,entryFileName], foregroundApp);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _playIndicator.hidden = YES;
                _playIndicator = nil;
            });
        }); 


    }

    notifyClient((UInt8*)"0 Script currently playing.\n\r", requestClient);
    NSLog(@"com.zjx.springboard: Script currently playing");
    return 0;
}

void playFromRawFile(NSString* filePath, NSString* foregroundApp)
{
    NSLog(@"com.zjx.springboard: Script now playing. Path: %@", filePath);

    isPlaying = true;

    bringAppForeground(foregroundApp);
    FILE *file = fopen([filePath UTF8String], "r");

    if (!file)
    {
        NSLog(@"com.zjx.springboard: cannot open file, file: %d", file);
        return;
    }
    
    char buffer[256];
    int taskType;
    int sleepTime;
    
    while (fgets(buffer, sizeof(char)*256, file) != NULL)
    {
        if (scriptPlayForceStop)
        {
            NSLog(@"com.zjx.springboard: Stop playing script. Force stopped. Path: %@", filePath);
            scriptPlayForceStop = false;
            break;
        }
        processTask((UInt8*)buffer);
    }

    isPlaying = false;
}

void playForceStop()
{
    scriptPlayForceStop = true;
}
