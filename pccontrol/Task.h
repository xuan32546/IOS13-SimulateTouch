#ifndef TASK_H
#define TASK_H


#define TASK_PERFORM_TOUCH 10
#define TASK_PROCESS_BRING_FOREGROUND 11
#define TASK_SHOW_ALERT_BOX 12
#define TASK_RUN_SHELL 13
#define TASK_TOUCH_RECORDING_START 14
#define TASK_TOUCH_RECORDING_STOP 15
#define TASK_CRAZY_TAP 16
#define TASK_DEPRICATED 17
#define TASK_USLEEP 18
#define TASK_PLAY_SCRIPT 19
#define TASK_PLAY_SCRIPT_FORCE_STOP 20
#define TASK_TEMPLATE_MATCH 21
#define TASK_SHOW_TOAST 22
#define TASK_COLOR_PICKER 23
#define TASK_TEXT_INPUT 24
#define TASK_TEST 99

void processTask(UInt8 *buff, CFWriteStreamRef writeStreamRef = NULL);
static int getTaskType(UInt8* dataArray);

#endif