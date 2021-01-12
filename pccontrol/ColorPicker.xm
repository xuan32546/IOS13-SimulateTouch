#include "ColorPicker.h"
#include "Screen.h"
#include "Image.h"

using namespace cv;
using namespace std;

NSDictionary* getRGBFromRawData(UInt8 *eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];
    if ([data count] < 2)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to pick color. The data format should be \"x;;y\"\r\n"}];
        return @{@"blue": @(-1), @"red": @(-1), @"green": @(-1)};
    }
    NSString *screenShotPath = [Screen screenShot];
    Mat screen = imread([screenShotPath UTF8String], IMREAD_COLOR);

    int x = [data[0] intValue];
    int y = [data[1] intValue];
    if (x > screen.cols)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;The range of the x coordinate should be less than the width of your screen. The width of your screen is %d. Your x: %d\r\n", screen.cols, x]}];
        return @{@"blue": @(-1), @"red": @(-1), @"green": @(-1)};
    }
    if (y > screen.rows)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;The range of the y coordinate should be less than the height of your screen. The height of your screen is %d. Your y: %d\r\n", screen.rows, y]}];
        return @{@"blue": @(-1), @"red": @(-1), @"green": @(-1)};
    }

    return [ColorPicker getRgbFromMat:screen x:x y:y];
}

@implementation ColorPicker
{

}

+ (NSDictionary*) getRgbFromMat:(Mat)img x:(int)x y:(int)y {
    NSLog(@"com.zjx.springboard: height: %d, width: %d, channels: %d. scale: %f", img.rows, img.cols, img.channels(), [Screen getScale]);

    Vec3b intensity = img.at<Vec3b>(y, x);
    // Don't know why. This version of opencv stores read at [0] rather than [2]
    uchar blue = intensity.val[0];
    uchar green = intensity.val[1];
    uchar red = intensity.val[2];
    NSLog(@"com.zjx.springboard: blue: %u, green: %u, red: %u.", blue, green, red);

    NSDictionary *result = @{@"blue": @(blue), @"red": @(red), @"green": @(green)};
    return result;
}



@end