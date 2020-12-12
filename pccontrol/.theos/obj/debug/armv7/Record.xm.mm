#line 1 "Record.xm"
#include "Record.h"
#include "Common.h"
#include "Config.h"
#include "AlertBox.h"
#include "Process.h"
#include "Screen.h"

static Boolean isRecording = false;
extern NSString *documentPath;

void startRecording()
{
    if (isRecording)
    {
        NSLog(@"com.zjx.springboard: recording already started.");
        return;
    }
    NSError *err = nil;

    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyMMddHHmmss"];
    NSString *currentDateTime = [outputFormatter stringFromDate:now];
    [outputFormatter release];

    
    
    NSString *scriptDirectory = [NSString stringWithFormat:@"%@/" RECORDING_FILE_FOLDER_NAME "/%@.bdl", getDocumentRoot(), currentDateTime];
    [[NSFileManager defaultManager] createDirectoryAtPath:scriptDirectory withIntermediateDirectories:YES attributes:nil error:&err];
    
    if (err)
    {
        NSLog(@"com.zjx.springboard: create script recording folder error. Error: %@", err);
        showAlertBox(@"Error", [NSString stringWithFormat:@"Cannot create script. Error info: %@", err], 999);
        return;
    }

    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    





    
    int orientation = getScreenOrientation();
    [infoDict setObject:[@(orientation) stringValue] forKey:@"Orientation"];

    
    id frontMostApp = getFrontMostApplication();
    
    if (frontMostApp == nil)
    {
        
        
    }
    else
    {
        NSLog(@"com.zjx.springboard: bundle identifier of front most application: %@, identifier: %@", frontMostApp, [frontMostApp displayIdentifier]);
        
    }

    
    [infoDict writeToFile:[NSString stringWithFormat:@"%@/%@.plist", scriptDirectory, currentDateTime] atomically:YES];

    NSLog(@"com.zjx.springboard: start recording.");
    
    























































}



































































