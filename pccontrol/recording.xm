static Boolean isRecording = false;

void startRecording()
{
    if (isRecording)
    {
        NSLog(@"com.zjx.springboard: recording already started.");
        return;
    }
    NSLog(@"com.zjx.springboard: start recording.");

    isRecording = true;

    id frontMostApp = getFrontMostApplication();


    if (frontMostApp == nil)
    {
        NSLog(@"com.zjx.springboard: foreground is springboard");
    }
    else
    {
        NSLog(@"com.zjx.springboard: bundle identifier of front most application: %@, identifier: %@", frontMostApp, [frontMostApp displayIdentifier]);
    }
    int screen_orientation = getScreenOrientation();

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *scriptDirectory = [NSString stringWithFormat:@"%@/zxtouchsp/recording/", [paths objectAtIndex:0]];

    NSError *err = nil;

    //create recording folder if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:scriptDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:scriptDirectory withIntermediateDirectories:YES attributes:nil error:&err]; //Create folder
    
    if (err)
    {
        NSLog(@"com.zjx.springboard: create script recording folder error. Error: %@", err);
        showAlertBox(@"Error", @"Cannot create script folder. Error code 1.", 999);
        return;
    }


    NSString *scriptRecordingFilePath = [NSString stringWithFormat:@"%@%@", scriptDirectory, recordingScriptName];
    NSLog(@"com.zjx.springboard: the recording file path is %@", scriptRecordingFilePath);

    //base content
    NSString *recordingFileBaseContent = @"import socket\nimport time\n\n# touch event types\nTOUCH_UP = 0\nTOUCH_DOWN = 1\nTOUCH_MOVE = 2\nSET_SCREEN_SIZE = 9\n\n# you can copy and paste these methods to your code\ndef formatSocketData(type, index, x, y):\n    return '{}{:02d}{:05d}{:05d}'.format(type, index, int(x*10), int(y*10))\n\n# need a very precise version of sleep\ndef sleep(seconds):\n    start_time = time.time()\n    seconds = int(seconds)\n    while time.time() - start_time < seconds:\n        pass\n\n\ns = socket.socket()\ns.connect((\"127.0.0.1\", 6000))\n#-------------------------------\n";
    NSData *recordingFileBaseContentData = [recordingFileBaseContent dataUsingEncoding:NSUTF8StringEncoding];

    //create file 
    if ( [[NSFileManager defaultManager] createFileAtPath:scriptRecordingFilePath contents:[NSData data] attributes:nil] != YES) //recordingFileBaseContentData
    {
        NSLog(@"com.zjx.springboard: creating script recording file error. ");
        showAlertBox(@"Error", @"Cannot create script file. Error code 2.", 999);
        return;
    }

    // open file handle
    scriptRecordingFileHandle = [NSFileHandle fileHandleForWritingAtPath:scriptRecordingFilePath];

    //set time stamp
    lastEventTimeStampForRecording = CFAbsoluteTimeGetCurrent();

    ioHIDEventSystemForRecording = IOHIDEventSystemClientCreate(kCFAllocatorDefault);

    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystemForRecording, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    //IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystemForRecording, (IOHIDEventSystemClientEventCallback)recordIOHIDEventCallback, NULL, NULL);


}