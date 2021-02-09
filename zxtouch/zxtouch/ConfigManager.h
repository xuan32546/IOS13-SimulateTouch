//
//  ConfigManager.h
//  zxtouch
//
//  Created by Jason on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigManager : NSObject
- (id)initWithPath:(NSString*)path;
- (void)updateKey:(NSString*)key forValue:(id)value;
- (NSMutableDictionary*)getConfigDictionary;
- (id)getValueFromKey:(NSString*)key;
- (void)save;
@end

NS_ASSUME_NONNULL_END
