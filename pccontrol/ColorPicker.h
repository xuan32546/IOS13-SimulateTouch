#ifndef COLOR_PICKER_H
#define COLOR_PICKER_H
#endif

#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#endif

NSDictionary* getRGBFromRawData(UInt8 *eventData, NSError **error);
NSString* searchRGBFromRawData(UInt8 *eventData, NSError **error);

@interface ColorPicker : NSObject
{

}
+ (NSString*) searchRGBFromMat:(cv::Mat)img region:(CGRect)region redMin:(int)redMin redMax:(int)redMax greenMin:(int)greenMin greenMax:(int)greenMax blueMin:(int)blueMin blueMax:(int)blueMax skip:(int)skip;
+ (NSDictionary*) getRgbFromMat:(cv::Mat)img x:(int)x y:(int)y;

@end