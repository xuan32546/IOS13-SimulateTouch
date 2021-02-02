#include "Task.h"
#include "Touch.h"
#include "Process.h"
#include "AlertBox.h"
#include "Record.h"
#include "Play.h"
#include "SocketServer.h"
#include "ScreenMatch.h"
#include "Toast.h"
#include "ColorPicker.h"
#include "UIKeyboard.h"
#include "DeviceInfo.h"
#include "TouchIndicator/TouchIndicatorWindow.h"
#import <mach/mach.h>
#include <Foundation/NSDistributedNotificationCenter.h>
#include <TextRecognization/TextRecognizer.h>

extern CFRunLoopRef recordRunLoop;

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
void processTask(UInt8 *buff, CFWriteStreamRef writeStreamRef)
{
    //NSLog(@"### com.zjx.springboard: task type: %d. Data: %s", getTaskType(buff), buff);

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
        notifyClient((UInt8*)"0\r\n", writeStreamRef); 
    }
    else if (taskType == TASK_SHOW_ALERT_BOX)
    {
        NSError *err = nil;
        showAlertBoxFromRawData(eventData, &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)"0\r\n", writeStreamRef);
        }
    }
    else if (taskType == TASK_USLEEP)
    {
        if (writeStreamRef)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
                notifyClient((UInt8*)"0;;Sleep ends\r\n", writeStreamRef); 
            });
        }
        else
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

    }
    else if (taskType == TASK_RUN_SHELL)
    {
        system([[NSString stringWithFormat:@"sudo zxtouchb -e \"%s\"", eventData] UTF8String]);
        notifyClient((UInt8*)"0\r\n", writeStreamRef); 
    }
    else if (taskType == TASK_TOUCH_RECORDING_START)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *err = nil;
            startRecording(writeStreamRef, &err);    
            if (err)
            {
                notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
            }
            else
            {
                notifyClient((UInt8*)"0\r\n", writeStreamRef);
            }
        });
    }
    else if (taskType == TASK_TOUCH_RECORDING_STOP)
    {
        stopRecording(); 
        notifyClient((UInt8*)"0\r\n", writeStreamRef); 
    }
    else if (taskType == TASK_PLAY_SCRIPT)
    {
        NSError *err = nil;
        playScript(eventData, &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)"0\r\n", writeStreamRef);
        }
    }
    else if (taskType == TASK_PLAY_SCRIPT_FORCE_STOP)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *err = nil;
            stopScriptPlaying(&err);
            if (err)
            {
                notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
            }
            else
            {
                notifyClient((UInt8*)"0\r\n", writeStreamRef);
            }
        });
    }
    else if (taskType == TASK_TEMPLATE_MATCH)
    {
        NSError *err = nil;
        CGRect result = screenMatchFromRawData(eventData, &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)[[NSString stringWithFormat:@"0;;%.2f;;%.2f;;%.2f;;%.2f\r\n", 
            result.origin.x, result.origin.y, result.size.width, result.size.height] UTF8String], writeStreamRef);
        }
    }
    else if (taskType == TASK_SHOW_TOAST)
    {
        NSError *err = nil;
        showToastFromRawData(eventData, &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)"0\r\n", writeStreamRef);
        }
    }
    else if (taskType == TASK_COLOR_PICKER)
    {
        NSError *err = nil;
        NSDictionary *rgb = getRGBFromRawData(eventData, &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)[[NSString stringWithFormat:@"0;;%d;;%d;;%d\r\n", [rgb[@"red"] intValue], [rgb[@"green"] intValue], [rgb[@"blue"] intValue]] UTF8String], writeStreamRef);
        }
    }
    else if (taskType == TASK_TEXT_INPUT)
    {
        NSError *err = nil;
        inputTextFromRawData(eventData,  &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)"0;;Successfully notify the appdelegate tweak. But not sure whether it works...\r\n", writeStreamRef);
        }
    }
    else if (taskType == TASK_GET_DEVICE_INFO)
    {
        NSError *err = nil;
        NSString *deviceInfo = getDeviceInfoFromRawData(eventData,  &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)[[NSString stringWithFormat:@"0;;%@\r\n", deviceInfo] UTF8String], writeStreamRef);
        }
    }
    else if (taskType == TASK_TOUCH_INDICATOR)
    {
        NSError *err = nil;
        handleTouchIndicatorTaskWithRawData(eventData, &err);
        if (err)
        {
            notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
        }
        else
        {
            notifyClient((UInt8*)"0\r\n", writeStreamRef);
        }
    }
    else if (taskType == TASK_TEXT_RECOGNIZER)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *err = nil;
            NSString *deviceInfo = performTextRecognizerTextFromRawData(eventData,  &err);
            if (err)
            {
                notifyClient((UInt8*)[[err localizedDescription] UTF8String], writeStreamRef);
            }
            else
            {
                notifyClient((UInt8*)[[NSString stringWithFormat:@"0;;%@\r\n", deviceInfo] UTF8String], writeStreamRef);
            }
        });
    }
    else if (taskType == TASK_TEST)
    {

    }
}