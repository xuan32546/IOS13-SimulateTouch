#line 1 "Touch.xm"
#include "Touch.h"
#include "Common.h"
#include "Screen.h"
#include "Task.h"


static CGFloat device_screen_width = 0;
static CGFloat device_screen_height = 0;

IOHIDEventSystemClientRef ioHIDEventSystemForSenderID = NULL;


unsigned long long int senderID = 0x0;






static int getTouchCountFromDataArray(UInt8* dataArray)
{
	int count = (dataArray[0] - '0');
	return count;
}




static int getTouchTypeFromDataArray(UInt8* dataArray, int index)
{
	int type = (dataArray[1+index*TOUCH_DATA_LEN] - '0');
	return type;
}




static int getTouchIndexFromDataArray(UInt8* dataArray, int index)
{
	int touchIndex = 0;
	for (int i = 2; i <= 3; i++)
	{
		touchIndex += (dataArray[i+index*TOUCH_DATA_LEN] - '0')*pow(10, 3-i);
	}
	return touchIndex;
}




static float getTouchXFromDataArray(UInt8* dataArray, int index)
{
	int x = 0;
	for (int i = 4; i <= 8; i++)
	{
		x += (dataArray[i+index*TOUCH_DATA_LEN] - '0')*pow(10, 8-i);
	}
	return x/10.0;
}





static float getTouchYFromDataArray(UInt8* dataArray, int index)
{
	int y = 0;
	for (int i = 9; i <= 13; i++)
	{
		y += (dataArray[i+index*TOUCH_DATA_LEN] - '0')*pow(10, 13-i);
	}
	return y/10.0;
}








static IOHIDEventRef generateChildEventTouchDown(int index, float x, float y)
{
	IOHIDEventRef child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index, 2, 35, x/device_screen_width, y/device_screen_height, 0.0f, 0.0f, 0.0f, 1, 1, 0);
    IOHIDEventSetFloatValue(child, 0xb0014, 0.04f); 
    IOHIDEventSetFloatValue(child, 0xb0015, 0.04f); 
	return child;
}








static IOHIDEventRef generateChildEventTouchMove(int index, float x, float y)
{
	IOHIDEventRef child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index, 2, 4, x/device_screen_width, y/device_screen_height, 0.0f, 0.0f, 0.0f, 1, 1, 0);
    IOHIDEventSetFloatValue(child, 0xb0014, 0.04f); 
    IOHIDEventSetFloatValue(child, 0xb0015, 0.04f); 
	return child;
}








static IOHIDEventRef generateChildEventTouchUp(int index, float x, float y)
{
	IOHIDEventRef child = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), index, 2, 33, x/device_screen_width, y/device_screen_height, 0.0f, 0.0f, 0.0f, 0, 0, 0);
    IOHIDEventSetFloatValue(child, 0xb0014, 0.04f); 
    IOHIDEventSetFloatValue(child, 0xb0015, 0.04f); 
	return child;
}




static void appendChildEvent(IOHIDEventRef parent, int type, int index, float x, float y)
{
    switch (type)
    {
        case TOUCH_MOVE:
			IOHIDEventAppendEvent(parent, generateChildEventTouchMove(index, x, y));
            break;
        case TOUCH_DOWN:
            IOHIDEventAppendEvent(parent, generateChildEventTouchDown(index, x, y));
            break;
        case TOUCH_UP:
            IOHIDEventAppendEvent(parent, generateChildEventTouchUp(index, x, y));
            break;
        default:
            NSLog(@"com.zjx.springboard: Unknown touch event type in appendChildEvent, type: %d", type);
    }
}





void performTouchFromRawData(UInt8 *eventData)
{
    
	IOHIDEventRef parent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, mach_absolute_time(), 3, 99, 1, 0, 0, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0, 0, 0); 
    IOHIDEventSetIntegerValue(parent , 0xb0019, 1); 
    IOHIDEventSetIntegerValue(parent , 0x4, 1); 

    for (int i = 0; i < getTouchCountFromDataArray(eventData); i++)
    {
        
        appendChildEvent(parent, getTouchTypeFromDataArray(eventData, i), getTouchIndexFromDataArray(eventData, i), getTouchXFromDataArray(eventData, i), getTouchYFromDataArray(eventData, i));
    }

    IOHIDEventSetIntegerValue(parent, 0xb0007, 0x23);
    IOHIDEventSetIntegerValue(parent, 0xb0008, 0x1);
    IOHIDEventSetIntegerValue(parent, 0xb0009, 0x1);

    postIOHIDEvent(parent);
    CFRelease(parent);
}




static void postIOHIDEvent(IOHIDEventRef event)
{
    static IOHIDEventSystemClientRef ioSystemClient = NULL;
    if (!ioSystemClient){
        ioSystemClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    }
	if (senderID != 0)
    	IOHIDEventSetSenderID(event, senderID);
	else
	{		
		NSLog(@"### com.zjx.springboard: sender id is 0!");
		return;
	}
    IOHIDEventSystemClientDispatchEvent(ioSystemClient, event);
}





static void setSenderIdCallback(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event)
{
    if (IOHIDEventGetType(event) == kIOHIDEventTypeDigitizer){
		if (senderID == 0)
        {
			senderID = IOHIDEventGetSenderID(event);
            NSLog(@"### com.zjx.springboard: sender id is: %qX", senderID);
        }
        if (ioHIDEventSystemForSenderID) 
        {
            IOHIDEventSystemClientUnregisterEventCallback(ioHIDEventSystemForSenderID);
            IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDEventSystemForSenderID, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            ioHIDEventSystemForSenderID = NULL;
        }
    }
}




void startSetSenderIDCallBack()
{
    ioHIDEventSystemForSenderID = IOHIDEventSystemClientCreate(kCFAllocatorDefault);

    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystemForSenderID, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystemForSenderID, (IOHIDEventSystemClientEventCallback)setSenderIdCallback, NULL, NULL);
    
}


void initTouchGetScreenSize()
{
    device_screen_width = [Screen getScreenWidth];
    device_screen_height = [Screen getScreenHeight];
}
