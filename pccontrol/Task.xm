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
}