#include "Record.h"
#include "Common.h"
#include "Config.h"
#include "AlertBox.h"
#include "Process.h"
#include "Screen.h"
#include "Window.h"
#include "SocketServer.h"

static CFRunLoopRef recordRunLoop = NULL;
static Boolean isRecording = false;
extern NSString *documentPath;
static NSFileHandle *scriptRecordingFileHandle = NULL;
static IOHIDEventSystemClientRef ioHIDEventSystemForRecording = NULL;
static CFAbsoluteTime lastEventTimeStampForRecording;

static CGFloat device_screen_width = 0;
static CGFloat device_screen_height = 0;

UIWindow *_recordIndicator;

void startRecording(CFWriteStreamRef requestClient, NSError **error)
{
   if (isRecording)
    {
        NSLog(@"com.zjx.springboard: recording has already started.");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Recording has already started.\r\n"}];
        return;
    }

    // get the screen size
    device_screen_width = [Screen getScreenWidth];
    device_screen_height = [Screen getScreenHeight];

    if (device_screen_width == 0 || device_screen_width == 0)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to start recording. Cannot get screen size.\r\n"}];
        showAlertBox(@"Error", @"Unable to start recording. Cannot get screen size.", 999);
        return;
    }
    
    NSError *err = nil;

    // get current time, we use time as the name of the script package
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyMMddHHmmss"];
    NSString *currentDateTime = [outputFormatter stringFromDate:now];

    
    // generate the script directory
    NSString *scriptDirectory = [NSString stringWithFormat:@"%@/" RECORDING_FILE_FOLDER_NAME "/%@.bdl", getDocumentRoot(), currentDateTime];
    [[NSFileManager defaultManager] createDirectoryAtPath:scriptDirectory withIntermediateDirectories:YES attributes:nil error:&err];
    
    if (err)
    {
        NSLog(@"com.zjx.springboard: create script recording folder error. Error: %@", err);
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Create script recording folder error.\r\n"}];
        showAlertBox(@"Error", [NSString stringWithFormat:@"Cannot create script. Error info: %@", err], 999);
        return;
    }

    // get basic info of current device 
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    [infoDict setObject:[NSString stringWithFormat:@"%@.raw", currentDateTime] forKey:@"Entry"];

    // orientation
    int orientation = [Screen getScreenOrientation];
    [infoDict setObject:[@(orientation) stringValue] forKey:@"Orientation"];

    // front most application
    SBApplication *frontMostApp = getFrontMostApplication();

    if (frontMostApp == nil)
    {
        //NSLog(@"com.zjx.springboard: foreground is springboard");
        [infoDict setObject:@"com.apple.springboard" forKey:@"FrontApp"];
    }
    else
    {
        NSLog(@"com.zjx.springboard: bundle identifier of front most application: %@, identifier: %@", frontMostApp, [frontMostApp displayIdentifier]);
        [infoDict setObject:[frontMostApp displayIdentifier] forKey:@"FrontApp"];
    }

    // write to plist file in script directory
    [infoDict writeToFile:[NSString stringWithFormat:@"%@/info.plist", scriptDirectory, currentDateTime] atomically:YES];


    // generate a raw file for writing
    NSString *rawFilePath = [NSString stringWithFormat:@"%@/%@.raw", scriptDirectory, currentDateTime];
    [[NSFileManager defaultManager] createFileAtPath:rawFilePath contents:nil attributes:nil];

    
    // start recording
    NSLog(@"com.zjx.springboard: start recording.");
    
    notifyClient((UInt8*)[scriptDirectory UTF8String], requestClient);

    isRecording = true;

    // show indicator
    dispatch_async(dispatch_get_main_queue(), ^{
        _recordIndicator = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];
        _recordIndicator.windowLevel = UIWindowLevelStatusBar;
        _recordIndicator.hidden = NO;
        [_recordIndicator setBackgroundColor:[UIColor clearColor]];

        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10*2,10*2)];

        //circleView.alpha = 1;
        circleView.layer.cornerRadius = 10;  // half the width/height
        circleView.backgroundColor = [UIColor redColor];
        [_recordIndicator addSubview:circleView];
    });

    scriptRecordingFileHandle = [NSFileHandle fileHandleForWritingAtPath:rawFilePath];

    // get time stamp
    lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();

    // start watching function
    ioHIDEventSystemForRecording = IOHIDEventSystemClientCreate(kCFAllocatorDefault);

    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystemForRecording, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystemForRecording, (IOHIDEventSystemClientEventCallback)recordIOHIDEventCallback, NULL, NULL);

    recordRunLoop = CFRunLoopGetCurrent();
    CFRunLoopRun();
}

//TODO: multi-touch support! get touch index automatically, rather than set to 7.
static void recordIOHIDEventCallback(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event) 
{
    //NSLog(@"### com.zjx.springboard: handle_event : %d", IOHIDEventGetType(event));
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


        /*
		if (senderID == 0)
			senderID = IOHIDEventGetSenderID(event);
        */

        NSLog(@"### com.zjx.springboard: x %f : y %f. eventMask: %d. index: %d, range: %d. Touch: %d", x, y, eventMask, index, range, touch);

        float sleepusecs = (CFAbsoluteTimeGetCurrent() - lastEventTimeStampForRecording)*1000000;
        float xToWrite =  x*device_screen_width*10;
        float yToWrite =  y*device_screen_height*10;
        //touch down or touch up
        if (eventMask == 33 || eventMask == 35 || eventMask == 2147)
        {
            [scriptRecordingFileHandle seekToEndOfFile];
            if ((range & touch) == 0) //touch up
            {
                NSLog(@"com.zjx.springboard: x %f : y %f. index: %d. Touch up.", x*device_screen_width, y*device_screen_height, index);
                [scriptRecordingFileHandle writeData:[[NSString stringWithFormat:@"18%.0f\n101007%05.0f%05.0f\n", sleepusecs, xToWrite, yToWrite] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if ((range & touch) == 1) //touch down
            {
                NSLog(@"com.zjx.springboard: x %f : y %f. index: %d. Touch down.", x*device_screen_width, y*device_screen_height, index);
                [scriptRecordingFileHandle writeData:[[NSString stringWithFormat:@"18%.0f\n101107%05.0f%05.0f\n", sleepusecs, xToWrite, yToWrite] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();
        }
        //touch move
        else if (eventMask == 4 || ((eventMask == 2052 || eventMask == 2050) && (touch == 1 && range == 1)))
        {
            NSLog(@"com.zjx.springboard: touch moved to (%f, %f). index: %d", x*device_screen_width, y*device_screen_height, index);
            [scriptRecordingFileHandle writeData:[[NSString stringWithFormat:@"18%.0f\n101207%05.0f%05.0f\n", sleepusecs, xToWrite, yToWrite] dataUsingEncoding:NSUTF8StringEncoding]];

            lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();
        }
        
        //else
        //{
        //    NSLog(@"### com.zjx.springboard: Unknown event. x %f : y %f. senderid: %qX. eventMask: %d. range: %d. Touch: %d", x, y, senderID, eventMask, range, touch);
        //}
        
    }
    else if (IOHIDEventGetType(event) == kIOHIDEventTypeButton)
    {
        NSLog(@"### com.zjx.springboard: type: button, senderID: %qX", IOHIDEventGetType(event), IOHIDEventGetSenderID(event));
    }
}

void stopRecording()
{
    NSLog(@"com.zjx.springboard: stop recording.");

    // remove indicator
    dispatch_async(dispatch_get_main_queue(), ^{
        _recordIndicator.hidden = YES;
        _recordIndicator = nil;
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
    if (recordRunLoop)
        CFRunLoopStop(recordRunLoop);
    
    recordRunLoop = NULL;

    //set this at last
    isRecording = false;
}

Boolean isRecordingStart()
{
    return isRecording;
}