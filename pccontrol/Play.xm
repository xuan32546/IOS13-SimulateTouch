#include "Play.h"
#include "SocketServer.h"
#include "Process.h"
#include "Task.h"
#include "AlertBox.h"
#include "Config.h"
#import "ScriptPlayer.h"
#include "Common.h"

ScriptPlayer *scriptPlayer;

void initScriptPlayer()
{
    scriptPlayer = [[ScriptPlayer alloc] init];
}

int playScript(UInt8* path, NSError **error)
{
    // read config file to get repeat time etc
    int repeatTime = 0;
    float sleepBetweenRun = 0;
    float playSpeed = 1.0f;
    

    NSMutableDictionary *config;
    if ([[NSFileManager defaultManager] fileExistsAtPath:SCRIPT_PLAY_CONFIG_PATH])
    {
        config = [[NSMutableDictionary alloc] initWithContentsOfFile:SCRIPT_PLAY_CONFIG_PATH];
        NSMutableDictionary *individualConfigs = [config valueForKey:@"individual_configs"];
        if (individualConfigs != nil)
        {
            NSMutableDictionary *scriptPlaybackInfo = [individualConfigs valueForKey:[NSString stringWithFormat:@"%s",path]];
            if (scriptPlaybackInfo != nil)
            {
                repeatTime = [scriptPlaybackInfo[@"repeat_times"] intValue];
                sleepBetweenRun = [scriptPlaybackInfo[@"interval"] floatValue];
                playSpeed = [scriptPlaybackInfo[@"speed"] floatValue];
            }
        }
    }
    

    [scriptPlayer setPath:[NSString stringWithFormat:@"%s", path]];
    [scriptPlayer setRepeatTime:repeatTime];
    [scriptPlayer setSpeed:playSpeed];
    [scriptPlayer setInterval:sleepBetweenRun];

    NSError *err = nil;
    [scriptPlayer play:&err];
    
    if (err)
    {
        *error = err;
    }

    return 0;
}


void stopScriptPlaying(NSError **error)
{
    [scriptPlayer forceStop:error];
}