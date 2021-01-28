#ifndef SCRIPT_PLAYER_H
#define SCRIPT_PLAYER_H

#endif

@interface ScriptPlayer : NSObject


- (void)setRepeatTime:(int)rt;
- (void)setInterval:(float)intv;
- (void)setSpeed:(float)sp;
- (void)setPath:(NSString*)path;
- (void)forceStop:(NSError**)error;
- (id)initWithPath:(NSString*)path;

- (int)play:(NSError**)error;
- (BOOL)isPlaying;
- (NSString*)getCurrentBundlePath;


@end