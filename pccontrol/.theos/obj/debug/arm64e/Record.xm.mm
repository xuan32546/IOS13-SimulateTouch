#line 1 "Record.xm"
#include "Record.h"
#include "Common.h"
#include "Config.h"
#include "AlertBox.h"
#include "Process.h"
#include "Screen.h"
#include "Window.h"

static Boolean isRecording = false;
extern NSString *documentPath;
static NSFileHandle *scriptRecordingFileHandle = NULL;
static IOHIDEventSystemClientRef ioHIDEventSystemForRecording = NULL;
static CFAbsoluteTime lastEventTimeStampForRecording;

extern CGFloat device_screen_width;
extern CGFloat device_screen_height;

UIWindow *_recordIndicator;

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
    [infoDict setObject:[NSString stringWithFormat:@"%@.raw", currentDateTime] forKey:@"Entry"];

    
    int orientation = getScreenOrientation();
    [infoDict setObject:[@(orientation) stringValue] forKey:@"Orientation"];

    
    id frontMostApp = getFrontMostApplication();
    
    if (frontMostApp == nil)
    {
        
        [infoDict setObject:@"com.apple.springboard" forKey:@"FrontApp"];
    }
    else
    {
        NSLog(@"com.zjx.springboard: bundle identifier of front most application: %@, identifier: %@", frontMostApp, [frontMostApp displayIdentifier]);
        [infoDict setObject:[frontMostApp displayIdentifier] forKey:@"FrontApp"];
    }

    
    [infoDict writeToFile:[NSString stringWithFormat:@"%@/info.plist", scriptDirectory, currentDateTime] atomically:YES];


    
    NSString *rawFilePath = [NSString stringWithFormat:@"%@/%@.raw", scriptDirectory, currentDateTime];
    [[NSFileManager defaultManager] createFileAtPath:rawFilePath contents:nil attributes:nil];

    
    
    NSLog(@"com.zjx.springboard: start recording.");
    isRecording = true;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        _recordIndicator = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];
        _recordIndicator.windowLevel = UIWindowLevelStatusBar;
        _recordIndicator.hidden = NO;
        [_recordIndicator setBackgroundColor:[UIColor clearColor]];

        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];

        
        circleView.layer.cornerRadius = 10;  
        circleView.backgroundColor = [UIColor redColor];
        [_recordIndicator addSubview:circleView];
    });

    scriptRecordingFileHandle = [NSFileHandle fileHandleForWritingAtPath:rawFilePath];

    
    lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();

    
    ioHIDEventSystemForRecording = IOHIDEventSystemClientCreate(kCFAllocatorDefault);

    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystemForRecording, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystemForRecording, (IOHIDEventSystemClientEventCallback)recordIOHIDEventCallback, NULL, NULL);

}


static void recordIOHIDEventCallback(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event) 
{
    
    if (!scriptRecordingFileHandle)
    {
        isRecording = false;

        showAlertBox(@"Error", @"Unknown error while recording script. Recording is now stopping. Error code: 31.", 999);
        return;
    }

    if (IOHIDEventGetType(event) == kIOHIDEventTypeDigitizer){
        IOHIDFloat x = IOHIDEventGetFloatValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerX);
        IOHIDFloat y = IOHIDEventGetFloatValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerY);
        int eventMask = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerEventMask);
        int range = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerRange);
        int touch = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerTouch);
        int index = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerIndex);


        




        NSLog(@"### com.zjx.springboard: x %f : y %f. eventMask: %d. index: %d, range: %d. Touch: %d", x, y, eventMask, index, range, touch);

        float sleepusecs = (CFAbsoluteTimeGetCurrent() - lastEventTimeStampForRecording)*1000000;
        float xToWrite =  x*device_screen_width*10;
        float yToWrite =  y*device_screen_height*10;
        
        if (eventMask == 33 || eventMask == 35 || eventMask == 2147)
        {
            [scriptRecordingFileHandle seekToEndOfFile];
            if ((range & touch) == 0) 
            {
                NSLog(@"com.zjx.springboard: x %f : y %f. index: %d. Touch up.", x*device_screen_width, y*device_screen_height, index);
                [scriptRecordingFileHandle writeData:[[NSString stringWithFormat:@"18%.0f\n101007%05.0f%05.0f\n", sleepusecs, xToWrite, yToWrite] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if ((range & touch) == 1) 
            {
                NSLog(@"com.zjx.springboard: x %f : y %f. index: %d. Touch down.", x*device_screen_width, y*device_screen_height, index);
                [scriptRecordingFileHandle writeData:[[NSString stringWithFormat:@"18%.0f\n101107%05.0f%05.0f\n", sleepusecs, xToWrite, yToWrite] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();
        }
        
        else if (eventMask == 4 || ((eventMask == 2052 || eventMask == 2050) && (touch == 1 && range == 1)))
        {
            NSLog(@"com.zjx.springboard: touch moved to (%f, %f). index: %d", x*device_screen_width, y*device_screen_height, index);
            [scriptRecordingFileHandle writeData:[[NSString stringWithFormat:@"18%.0f\n101207%05.0f%05.0f\n", sleepusecs, xToWrite, yToWrite] dataUsingEncoding:NSUTF8StringEncoding]];

            lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();
        }
        
        
        
        
        
        
    }
    else if (IOHIDEventGetType(event) == kIOHIDEventTypeButton)
    {
        NSLog(@"### com.zjx.springboard: type: button, senderID: %qX", IOHIDEventGetType(event), IOHIDEventGetSenderID(event));
    }
}

void stopRecording()
{
    NSLog(@"com.zjx.springboard: stop recording.");

    
    dispatch_async(dispatch_get_main_queue(), ^{
        _recordIndicator.hidden = YES;
        [_recordIndicator release];
    });

    
    if (ioHIDEventSystemForRecording)
    {
        IOHIDEventSystemClientUnregisterEventCallback(ioHIDEventSystemForRecording);
        IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDEventSystemForRecording, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

        ioHIDEventSystemForRecording = NULL;
    }

    if (scriptRecordingFileHandle)
    {
        [scriptRecordingFileHandle synchronizeFile];
        [scriptRecordingFileHandle closeFile];

        scriptRecordingFileHandle = nil;
    }

    
    isRecording = false;
}
