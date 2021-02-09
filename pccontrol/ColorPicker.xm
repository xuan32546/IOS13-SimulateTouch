#include "ColorPicker.h"
#include "Screen.h"
#include "Image.h"

#define COLOR_SEARCHER_SEARCH_SINGLE_POINT 1

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
    if (screen.rows == 0 && screen.cols == 0)
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to pick color. The screenshot image cannot be read. Height and width is 0!\r\n"}];
        return @{@"blue": @(-1), @"red": @(-1), @"green": @(-1)};
    }

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

NSString* searchRGBFromRawData(UInt8 *eventData, NSError **error)
{
    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];

    int searchType = [data[0] intValue];

    if (searchType == COLOR_SEARCHER_SEARCH_SINGLE_POINT)
    {
        if ([data count] < 12)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to search color. The data format should be \"searchtype;;x;;y;;width;;height;;redMin;;redMax;;greenMin;;greenMax;;blueMin;;blueMax;;skip\"\r\n"}];
            return @"";
        }
        NSString *screenShotPath = [Screen screenShot];
        Mat screen = imread([screenShotPath UTF8String], IMREAD_COLOR);
        if (screen.rows == 0 && screen.cols == 0)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to search color. The screenshot image cannot be read. Height and width is 0!\r\n"}];
            return @"";
        }

        int x = [data[1] intValue];
        int y = [data[2] intValue];
        int width =  [data[3] intValue];
        int height =  [data[4] intValue];
        int redMin = [data[5] intValue];
        int redMax = [data[6] intValue];
        int greenMin =  [data[7] intValue];
        int greenMax =  [data[8] intValue];
        int blueMin =  [data[9] intValue];
        int blueMax =  [data[10] intValue];
        int skip =  [data[11] intValue];

        if (x > screen.cols)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;The range of the x coordinate should be less than the width of your screen. The width of your screen is %d. Your x: %d\r\n", screen.cols, x]}];
            return @"";
        }
        if (y > screen.rows)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;The range of the y coordinate should be less than the height of your screen. The height of your screen is %d. Your y: %d\r\n", screen.rows, y]}];
            return @"";
        }
        if (redMax < 0 || redMin < 0 || redMax > 255 || redMin > 255 || redMax < redMin)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Max red rgb and min reb rgb should <= 255  && >= 0 and max red rgb should be <= red min rgb. You redMax: %d, redMin: %d\r\n", redMax, redMin]}];
            return @"";
        }
        if (greenMax < 0 || greenMin < 0 || greenMax > 255 || greenMin > 255 || greenMax < greenMin)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Max green rgb and min green rgb should <= 255 && >= 0 and max green rgb should be <= green min rgb. You greenMax: %d, greenMin: %d\r\n", greenMax, greenMin]}];
            return @"";
        }
        if (blueMax < 0 || blueMin < 0 || blueMax > 255 || blueMin > 255 || blueMax < blueMin)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Max blue rgb and min blue rgb should <= 255 && >= 0  and max blue rgb should be <= blue min rgb. You blueMax: %d, blueMin: %d\r\n", blueMax, blueMin]}];
            return @"";
        }
        if (skip < 0)
        {
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Skip cannot be negative\r\n", skip]}];
            return @"";
        }


        if (width <= 0 || x + width > screen.cols)
        {
            width = screen.cols - x;
        }    
        if (height <= 0 || y + height > screen.rows)
        {
            height = screen.rows - y;
        }

        return [ColorPicker searchRGBFromMat:screen region:CGRectMake(x, y, width, height) redMin:redMin redMax:redMax greenMin:greenMin greenMax:greenMax blueMin:blueMin blueMax:blueMax skip:skip];
    }
    else
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Unable to search color. Unknown search color task type.\r\n"}];
        return nil;
    }

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

+ (NSString*) searchRGBFromMat:(Mat)img region:(CGRect)region redMin:(int)redMin redMax:(int)redMax greenMin:(int)greenMin greenMax:(int)greenMax blueMin:(int)blueMin blueMax:(int)blueMax skip:(int)skip {
    NSLog(@"com.zjx.springboard: image height: %d, width: %d, channels: %d. scale: %f. Rect: %@. skip: %d. redSearch: (%d, %d), greenSearch: (%d, %d), blueSearch: (%d, %d)", img.rows, img.cols, img.channels(), [Screen getScale], NSStringFromCGRect(region), skip, redMin, redMax, greenMin, greenMax, blueMin, blueMax);
    
    int x = region.origin.x;
    int y = region.origin.y;

    int width = region.size.width;
    int height = region.size.height;

    int searchMaxX = x + width;
    int searchMaxY = y + height;

    for (int currentY = y; currentY <= searchMaxY; currentY += skip + 1)
    {
        for (int currentX = x; currentX <= searchMaxX; currentX += skip + 1)
        {
            Vec3b intensity = img.at<Vec3b>(currentY, currentX);
            uchar blue = intensity.val[0];
            uchar green = intensity.val[1];
            uchar red = intensity.val[2];

            //NSLog(@"com.zjx.springboard: x: %d, y: %d, blue: %u, green: %u, red: %u.", currentX, currentY, blue, green, red);
            if (red >= redMin && red <= redMax && green >= greenMin && green <= greenMax && blue >= blueMin && blue <= blueMax)
            {
                return [NSString stringWithFormat:@"%d;;%d;;%d;;%d;;%d", currentX, currentY, red, green, blue];
            }
        }
    }

    return @"-1;;-1;;-1";
}




@end