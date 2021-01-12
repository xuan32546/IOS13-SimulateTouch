#ifndef COLOR_PICKER_H
#define COLOR_PICKER_H
#endif

#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#endif

NSDictionary* getRGBFromRawData(UInt8 *eventData, NSError **error);


@interface ColorPicker : NSObject
{

}

+ (NSDictionary*) getRgbFromMat:(cv::Mat)img x:(int)x y:(int)y;

@end