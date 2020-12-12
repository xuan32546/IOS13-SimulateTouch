#include "Task.h"
#include "Touch.h"
#include "Process.h"
#include "AlertBox.h"
#include "Record.h"
#include "Play.h"
/*
get task type
*/
static int getTaskType(UInt8* dataArray)
{
	int taskType = 0;
	for (int i = 0; i <= 1; i++)
	{
		taskType += (dataArray[i] - '0')*pow(10, 1-i);
	}
	return taskType;
}

/**
Process Task
*/
void processTask(UInt8 *buff)
{
    NSLog(@"### com.zjx.springboard: task type: %d. Data: %s", getTaskType(buff), buff);

    UInt8 *eventData = buff + 0x2;
    int taskType = getTaskType(buff);


    //for touching
    if (taskType == TASK_PERFORM_TOUCH)
    {
        performTouchFromRawData(eventData);
    }
    else if (taskType == TASK_PROCESS_BRING_FOREGROUND) //bring to foreground
    {
        switchProcessForegroundFromRawData(eventData);
    }
    else if (taskType == TASK_SHOW_ALERT_BOX)
    {
        showAlertBoxFromRawData(eventData);
    }
    else if (taskType == TASK_USLEEP)
    {
        int usleepTime = 0;

        @try{
            usleepTime = atoi((char*)eventData);
        }
        @catch (NSException *exception) {
            NSLog(@"com.zjx.springboard: Debug: %@", exception.reason);
            return;
        }
        //NSLog(@"com.zjx.springboard: sleep %d microseconds", usleepTime);
        usleep(usleepTime);
    }
    else if (taskType == TASK_RUN_SHELL)
    {
        system([[NSString stringWithFormat:@"sudo zxtouchb -e \"%s\"", eventData] UTF8String]);
    }
    else if (taskType == TASK_TOUCH_RECORDING_START)
    {
        startRecording();    
        
        /*
        FILE *file = fopen("/var/mobile/Documents/com.zjx.zxtouchsp/recording/201210140654.bdl/201210140654.raw", "r");
    
        char buffer[256];
        int taskType;
        int sleepTime;
        
        while (fgets(buffer, sizeof(char)*256, file) != NULL){
            processTask((UInt8 *)buffer);
            //NSLog(@"%s",buffer);
        }
        */
        
    }
    else if (taskType == TASK_TOUCH_RECORDING_STOP)
    {
        stopRecording();    
    }
    else if (taskType == TASK_PLAY_SCRIPT)
    {
        playScript(eventData);
    }
    else if (taskType == TASK_PLAY_SCRIPT_FORCE_STOP)
    {
        playForceStop();
    }
    /*
    else if (taskType == TASK_TOUCH_RECORDING_END)
    {
        NSLog(@"com.zjx.springboard: stop recording.");


        if (ioHIDEventSystemForRecording)
        {
            IOHIDEventSystemClientUnregisterEventCallback(ioHIDEventSystemForRecording);
            IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDEventSystemForRecording, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

            ioHIDEventSystemForRecording = NULL;
        }

        if (scriptRecordingFileHandle)
        {
            //[scriptRecordingFileHandle seekToEndOfFile];
            //[scriptRecordingFileHandle writeData:[@"\ns.close()" dataUsingEncoding:NSUTF8StringEncoding]];
            [scriptRecordingFileHandle synchronizeFile];
            [scriptRecordingFileHandle closeFile];

            scriptRecordingFileHandle = nil;
        }


        //set this at last
        isRecording = false;
    }
    */
    /*
    else if (taskType == TASK_CRAZY_TAP)
    {

        NSString *crazyTapData = [NSString stringWithFormat:@"%s", eventData];
        NSArray *crazyTapDataArray = [crazyTapData componentsSeparatedByString:@";;"];

        float x, y, elapseTime;
        int countToStop, sleepUTime;

        @try{
            x = [crazyTapDataArray[0] floatValue];
            y = [crazyTapDataArray[1] floatValue];
            elapseTime = [crazyTapDataArray[2] floatValue];
            countToStop = [crazyTapDataArray[3] intValue];
            sleepUTime = [crazyTapDataArray[4] intValue];
        }
        @catch (NSException *exception) {
            NSLog(@"com.zjx.springboard: crazy tap not enough argument. Expected: 5. Debug: %@", exception.reason);
            return;
        }
        NSLog(@"com.zjx.springboard: crazy tap x: %f, y: %f, elapse time: %f, count: %d, sleepTime: %d", x, y, elapseTime, countToStop, sleepUTime);

        //set timer (not accurate timer!)
        if (elapseTime > 0)
        {
            signal(SIGALRM, crazyTapTimeUpCallback);
            ualarm(elapseTime*1000000, 0);
        }

        
        isCrazyTapping = true;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int countToStopBlock = countToStop;
            IOHIDEventRef parent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, mach_absolute_time(), 3, 99, 1, 0, 0, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0, 0, 0); 
            IOHIDEventSetIntegerValue(parent , 0xb0019, 1); //set flags of parent event   flags: 0x20001 -> 0xa0001
            IOHIDEventSetIntegerValue(parent , 0x4, 1); //set flags of parent event   flags: 0xa0001 -> 0xa0011

            IOHIDEventAppendEvent(parent, generateChildEventTouchDown(9, x, y));
            IOHIDEventAppendEvent(parent, generateChildEventTouchUp(9, x, y));

            IOHIDEventSetIntegerValue(parent, 0xb0007, 0x23); // 设置parent的EventMask == 35
            IOHIDEventSetIntegerValue(parent, 0xb0008, 0x1); // parent flags: 0xa0011 -> 0xb0011
            IOHIDEventSetIntegerValue(parent, 0xb0009, 0x1); // 不知道设置哪里
            
            if (countToStop <= 0)
            {
                while (true)
                {
                    if (!isCrazyTapping)
                        break;

                    postIOHIDEvent(parent);
                    usleep(sleepUTime);
                }
            }
            else
            {
                int count = 0;
                while (count < countToStopBlock)
                {
                    if (!isCrazyTapping)
                        break;

                    postIOHIDEvent(parent);
                    usleep(sleepUTime);

                    count++;
                }
            }

            CFRelease(parent);
        });
        
    }
    */
    /*
    else if (taskType == EXECUTE_TASK_FROM_SHELL_OUTPUT) //run script which is written in our language
    {
        __block UInt8 *eventDataBlock = eventData;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FILE *fp;
            char buffer[2048];
            
            fp=popen([[NSString stringWithFormat:@"sudo zxtouchb --execute-command \"%s\"", eventDataBlock] UTF8String], "r");    //以读方式，fork产生一个子进程，执行shell命令

            while (true) {
                    if (fgets(buffer, sizeof(buffer), fp) == NULL) break;
                    if (buffer[0] == 'z' && buffer[1] == 'x' && buffer[2] == 'r' && buffer[3] == 'u' && buffer[4] == 'n') //TODO: rewrite this
                    {
                        processTask((UInt8 *)(buffer+6));
                    }
                    NSLog(@"com.zjx.springboard: output: %s", buffer);
            }

            pclose(fp);
        });

    }
    */
}