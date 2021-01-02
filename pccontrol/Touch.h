#ifndef TOUCH_H
#define TOUCH_H

#include "headers/IOHIDEvent.h"
#include "headers/IOHIDEventData.h"
#include "headers/IOHIDEventTypes.h"
#include "headers/IOHIDEventSystemClient.h"
#include "headers/IOHIDEventSystem.h"

#include <mach/mach_time.h>

#define TOUCH_UP 0
#define TOUCH_DOWN 1
#define TOUCH_MOVE 2

const int TOUCH_DATA_LEN = 13;

static int getTouchCountFromDataArray(UInt8* dataArray);
static int getTouchTypeFromDataArray(UInt8* dataArray, int index);
static int getTouchIndexFromDataArray(UInt8* dataArray, int index);
static float getTouchXFromDataArray(UInt8* dataArray, int index);
static float getTouchYFromDataArray(UInt8* dataArray, int index);
void performTouchFromRawData(UInt8 *eventData);

static IOHIDEventRef generateChildEventTouchDown(int index, float x, float y);
static IOHIDEventRef generateChildEventTouchMove(int index, float x, float y);
static IOHIDEventRef generateChildEventTouchUp(int index, float x, float y);

static void postIOHIDEvent(IOHIDEventRef event);
static void setSenderIdCallback(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event);
void startSetSenderIDCallBack();

void initTouchGetScreenSize();

#endif