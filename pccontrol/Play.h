#ifndef PLAY_H
#define PLAY_H

int playScript(UInt8* path);
void playFromRawFile(NSString* filePath, NSString* foregroundApp);
void playForceStop();

#endif