//
//  ConfigManager.m
//  zxtouch
//
//  Created by Jason on 2021/2/9.
//

#import "ConfigManager.h"

@implementation ConfigManager
{
    NSString* configPath;
    NSMutableDictionary *config;
}

- (id)initWithPath:(NSString*)path {
    self = [super init];
    if (self)
    {
        configPath = path;
        config = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        if (!config)
        {
            config = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)updateKey:(NSString*)key forValue:(id)value {
    config[key] = value;
}

- (id)getValueFromKey:(NSString*)key {
    return config[key];
}

- (NSMutableDictionary*)getConfigDictionary {
    return config;
}



- (void)save {
    [config writeToFile:configPath atomically:YES];
}

@end
