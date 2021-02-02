#ifndef TEXT_RECOGNIZER_H
#define TEXT_RECOGNIZER_H

#define TASK_TEXT_FROM_AREA 1
#define TASK_GET_SUPPORTED_LANGUAGE_LIST 2

NSString* performTextRecognizerTextFromRawData(UInt8* eventData, NSError** error);

#endif

