//
//  TemplateMatch.cpp
//  OpenCVTest
//
//  Created by Yun CHEN on 2018/2/8.
//  Copyright © 2018年 Yun CHEN. All rights reserved.
//


#import "TemplateMatch.h"
#include <vector>
#include <math.h>



using namespace cv;
using namespace std;



@interface TemplateMatch() {
    UIImage *_templateImage;
    vector<Mat> _scaledTempls;
    int maxTryTimes;
    float acceptableValue;
    float scaleRation;
}

@end



@implementation TemplateMatch

//static float resizeRatio = 0.35;              //原图缩放比例，越小性能越好，但识别度越低
//static int maxTryTimes = 4;                   //未达到预定识别度时，再尝试的次数限制
//static float acceptableValue = 0.9;           //达到此识别度才被认为正确
//static float scaleRation = 0.75;              //当模板未被识别时，尝试放大/缩小模板。 指定每次模板缩小的比例

- (void)setScaleRation:(float)sr {
    scaleRation = sr;
}

- (void)setAcceptableValue:(float)av {
    acceptableValue = av;
}

- (void)setMaxTryTimes:(int)mtt {
    maxTryTimes = mtt;
}

- (CGRect)templateMatchWithPath:(NSString*)imgPath templatePath:(NSString*)templatePath {
    Mat image = imread([imgPath UTF8String], CV_LOAD_IMAGE_GRAYSCALE); //[imgPath UTF8String]
    Mat templ = imread([templatePath UTF8String], CV_LOAD_IMAGE_GRAYSCALE); //[templatePath UTF8String]
    return [self matchWithMat:image andTemplate:templ];
}

//uncompleted
- (CGRect)templateMatchWithUIImage:(UIImage*)img template:(UIImage*)templ {
    //return [self matchWithMat:[self cvMatFromUIImage:img] andTemplate:[self cvMatFromUIImage:templ]];
    return CGRect();
}

//调用OpenCV进行匹配
//此方法具体解释参考OpenCV官方文档: https://docs.opencv.org/3.2.0/de/da9/tutorial_template_matching.html
- (CGRect)matchWithMat:(Mat)img andTemplate:(Mat)templ {
    double minVal;
    double maxVal;
    cv::Point minLoc;
    cv::Point maxLoc;

    _scaledTempls.push_back(templ);

    Mat templResized;

    //由于模板图和原图大小比例不一致，需要放大缩小模板图，来多次比较。所以建立不同比例的模板图。
    for(int i=0;i<maxTryTimes;i++) {
        //放大模板图
        float powIncreaRation = pow(2 - scaleRation, i+1);
        resize(templ, templResized, cv::Size(0, 0), powIncreaRation, powIncreaRation);
        _scaledTempls.push_back(templResized); //由于push_back方法执行值拷贝，所以可以复用templResized变量。
        
        //缩小模板图
        float powReduceRation = pow(scaleRation, i+1);
        resize(templ, templResized, cv::Size(0, 0), powReduceRation, powReduceRation);
        _scaledTempls.push_back(templResized);
    }

    //匹配不同大小的模板图

    //创建结果矩阵，用于存放单次匹配到的位置信息(单次会匹配到很多，后面根据不同算法取最大或最小值)
        //匹配不同大小的模板图
    for (int i=0; i < _scaledTempls.size(); i++) {
        Mat currentTemplate = _scaledTempls[i];

        int result_cols = img.cols - currentTemplate.cols + 1;
        int result_rows = img.rows - currentTemplate.rows + 1;
        Mat result;
        result.create(result_rows, result_cols, CV_32FC1);

        //OpenCV匹配
        matchTemplate(img, currentTemplate, result, TM_CCOEFF_NORMED);

        //整理出本次匹配的最大最小值
        minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc, Mat());
        
        //TM_CCOEFF_NORMED算法，取最大值为最佳匹配
        //当最大值符合要求，认为匹配成功
        if (maxVal >= acceptableValue) {
            //NSLog(@"matched point:%d,%d maxVal:%f, tried times:%d",maxLoc.x,maxLoc.y,maxVal,i + 1);
            NSLog(@"com.zjx.springboard: match success. x: %d, y: %d. width: %d, height: %d", maxLoc.x, maxLoc.y, currentTemplate.rows, currentTemplate.cols);
            return CGRectMake(maxLoc.x, maxLoc.y, currentTemplate.rows, currentTemplate.cols);
        }
        NSLog(@"com.zjx.springboard: match failed for template index: %d", i);
    }
    
    //未匹配到，则返回空区域
    NSLog(@"com.zjx.springboard: match failed");
    return CGRect();
}

//UIImage转为OpenCV灰图矩阵
- (Mat)cvMatGrayFromUIImage:(UIImage *)image {
    Mat img;
    Mat img_color = [self cvMatFromUIImage:image];
    cvtColor(img_color, img, COLOR_BGR2GRAY);
    
    return img;
}

//UIImage转为OpenCV矩阵 BUGS exists for color picker!!! Do NOT USE THIS
- (Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4); // 8位图, 4通道 (颜色 通道 + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // 数据来源
                                                    cols,                       // 宽
                                                    rows,                       // 高
                                                    8,                          // 8位
                                                    cvMat.step[0],              // 每行字节
                                                    colorSpace,                 // 颜色空间
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap图信息
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//Buffer转为OpenCV矩阵
- (Mat)cvMatFromBuffer:(CMSampleBufferRef)buffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    //取得高宽，以及数据起始地址
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    //转为OpenCV矩阵
    Mat mat = Mat(bufferHeight,bufferWidth,CV_8UC4,pixel,CVPixelBufferGetBytesPerRow(pixelBuffer));
    
    //结束处理
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    //转为灰度图矩阵
    Mat matGray;
    cvtColor(mat, matGray, COLOR_BGR2GRAY);
    
    return matGray;
}


@end
