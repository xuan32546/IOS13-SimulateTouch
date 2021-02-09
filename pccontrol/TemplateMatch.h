#ifndef TEMPLATE_MATCH_H
#define TEMPLATE_MATCH_H
#endif 

#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#endif


//
//  TemplateMatch.hpp
//  OpenCVTest
//
//  Created by Yun CHEN on 2018/2/8.
//  Copyright © 2018年 Yun CHEN. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <opencv2/imgcodecs/ios.h>

@interface TemplateMatch : NSObject

@property(nonatomic,strong) UIImage *templateImage;     //模板图片。由于匹配方法会被多次调用，所以模板图片适合单次设定。

//在Buffer中匹配预设的模板，如果成功则返回位置以及区域大小。
//这里返回的Rect基于AVCapture Metadata的坐标系统，即值在0.0-1.0之间，方便AVCaptureVideoPreviewLayer类进行转换。
- (CGRect)templateMatchWithPath:(NSString*)imgPath templatePath:(NSString*)templatePath error:(NSError**)err;
- (CGRect)templateMatchWithUIImage:(UIImage*)img template:(UIImage*)templ;

- (void)setScaleRation:(float)sr;
- (void)setAcceptableValue:(float)av;
- (void)setMaxTryTimes:(int)mtt;

@end