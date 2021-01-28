#ifndef PLAY_H
#define PLAY_H

int playScript(UInt8* path, NSError** error);
void playFromRawFile(NSString* filePath, NSString* foregroundApp, NSError **err);
void playFromPythonFile(NSString* filePath, NSString* foregroundApp, NSError **err);
void stopScriptPlaying(NSError **error);
void playHasStoppedCallBack();
void initScriptPlayer();

#endif