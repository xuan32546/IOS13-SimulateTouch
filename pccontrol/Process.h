#ifndef PROCESS_H
#define PROCESS_H

#include <dlfcn.h>

int switchProcessForegroundFromRawData(UInt8 *eventData);
int bringAppForeground(NSString *appIdentifier);
id getFrontMostApplication();

#endif