#include "Play.h"
#include "SocketServer.h"
#include "Process.h"
#include "Task.h"
#include "AlertBox.h"

BOOL isPlaying = false;
BOOL scriptPlayForceStop = false;
UIWindow *_playIndicator;

int playScript(UInt8* path, NSError **error)
{
    if (isPlaying)
    {
        NSLog(@"com.zjx.springboard: Unable to run the script. Another script is currently running.");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to run the script. Another script is currently running.\r\n"}];
        return -1;
    }

    // check folder exists
    NSLog(@"com.zjx.springboard: dictionary path: %@", [NSString stringWithFormat:@"%s/", path]);

    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%s", path] isDirectory:&isDir] || !isDir)
    {
        NSLog(@"com.zjx.springboard: Unable to run the script. Path not found or it is not a directory.");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to run the script. Path not found or it is not a directory.\r\n"}];
        return -1;
    }
    // read info.plist into dictionary
    NSString *infoFilePath = [NSString stringWithFormat:@"%s/info.plist", path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoFilePath isDirectory:&isDir])
    {
        NSLog(@"com.zjx.springboard: Unable to run the script. Info.plist not found.");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to run the script. Info.plist not found.\r\n"}];
        return -1;
    }
    NSDictionary *scriptInfo = [NSDictionary dictionaryWithContentsOfFile:infoFilePath];
    // get entry file extension
    NSString *entryFileName = scriptInfo[@"Entry"];
    NSString *fileExtension = [entryFileName pathExtension];

    NSString *foregroundApp = scriptInfo[@"FrontApp"];
    // call different functions depending on file extension

        // show indicator
    dispatch_async(dispatch_get_main_queue(), ^{
        _playIndicator = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];
        _playIndicator.windowLevel = UIWindowLevelStatusBar;
        _playIndicator.hidden = NO;
        [_playIndicator setBackgroundColor:[UIColor clearColor]];
        [_playIndicator setUserInteractionEnabled:NO];

        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];

        //circleView.alpha = 1;
        circleView.layer.cornerRadius = 10;  // half the width/height
        circleView.backgroundColor = [UIColor greenColor];
        [_playIndicator addSubview:circleView];
    });

    NSString *entryFilePath = [NSString stringWithFormat:@"%s/%@", path,entryFileName];
    NSLog( [NSString stringWithFormat:@"com.zjx.springboard: path is: %s/", path]);
    NSLog( @"com.zjx.springboard: %@", entryFilePath);
    if ([fileExtension isEqualToString:@"raw"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *err = nil;
            playFromRawFile(entryFilePath, foregroundApp, &err);
            // remove indicator
            dispatch_async(dispatch_get_main_queue(), ^{
                _playIndicator.hidden = YES;
                _playIndicator = nil;
            });
        }); 
    }
    else if ([fileExtension isEqualToString:@"py"])
    {

        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *err = nil;
            playFromPythonFile(entryFilePath, foregroundApp, &err);
            // remove indicator
            dispatch_async(dispatch_get_main_queue(), ^{
                _playIndicator.hidden = YES;
                _playIndicator = nil;
            });
        }); 
    }

    NSLog(@"com.zjx.springboard: Script start playing");
    return 0;
}

void playFromRawFile(NSString* filePath, NSString* foregroundApp, NSError **err)
{
    NSLog(@"com.zjx.springboard: Script now playing. Path: %@", filePath);

    isPlaying = true;

    bringAppForeground(foregroundApp);
    FILE *file = fopen([filePath UTF8String], "r");

    if (!file)
    {
        showAlertBox(@"Error", [NSString stringWithFormat:@"Cannot play this script because zxtouch cannot open the file. File path: %@", filePath], 999);
        isPlaying = false;
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
        processTask((UInt8*)buffer, NULL);
    }

    isPlaying = false;
}

void playFromPythonFile(NSString* filePath, NSString* foregroundApp, NSError **err)
{
    NSLog(@"com.zjx.springboard: Script now playing. Path: %@", filePath);

    isPlaying = true;

    bringAppForeground(foregroundApp);

    // check python exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/bin/python3"])
    {
        showAlertBox(@"Error", @"Cannot play this script. /bin/python3 not found. Please install Python3.7 on your device.", 999);
        isPlaying = false;
        return;
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        showAlertBox(@"Error", [NSString stringWithFormat:@"Cannot play this script. Script file not found in bdl folder. Script path: %@", filePath], 999);
        isPlaying = false;
        return;
    }
    NSLog(@"com.zjx.springboard: command %@", [NSString stringWithFormat:@"sudo zxtouchb -e \"python3 -u \\\"%@\\\" 2>&1 | /var/mobile/Library/ZXTouch/coreutils/ScriptRuntime/add_datetime.sh | tee -a /var/mobile/Library/ZXTouch/coreutils/ScriptRuntime/output\"", filePath]);

    system([[NSString stringWithFormat:@"sudo zxtouchb -e \"python3 -u \\\"%@\\\" 2>&1 | /var/mobile/Library/ZXTouch/coreutils/ScriptRuntime/add_datetime.sh \\\"%@\\\" | tee -a /var/mobile/Library/ZXTouch/coreutils/ScriptRuntime/output\"", filePath, filePath] UTF8String]);
    // add force stop

    isPlaying = false;
}

void playForceStop()
{
    scriptPlayForceStop = true;
}