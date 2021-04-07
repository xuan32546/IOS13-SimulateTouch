#include "TextRecognizer.h"
#import "VKOcrManager.h"
#import "../Screen.h"
#include "../Common.h"
#include "../AlertBox.h"

NSString* performTextRecognizerTextFromRawData(UInt8* eventData, NSError** error)
{
    if (SYSTEM_VERSION_LESS_THAN(@"13.0"))
    {
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;OCR only supports iOS13 or newer version of iOS. iOS12 or older may be supported in the future.\r\n"}];
        showAlertBox(@"Not Supported", @"OCR only supports iOS13 or newer version of iOS. iOS12 and older may be supported in the future.", 99);
        return nil;
    }

    NSArray *data = [[NSString stringWithFormat:@"%s", eventData] componentsSeparatedByString:@";;"];
    if ([data count] == 0)
    {
        NSLog(@"com.zjx.springboard: Data not in good format.");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Data not in good format.\r\n"}];
        return nil;
    }

    int task = [data[0] intValue];

    if (task == TASK_TEXT_FROM_AREA) // format: 1;;x1,y1,x2,y2;;custom_words;;minimum_height;;level;;languages;;correct;;debug_path
    {
        if ([data count] < 8)
        {
            NSLog(@"com.zjx.springboard: Data not in good format. The format should be 1;;x1,,y1,,width,,height;;custom_words;;minimum_height;;level;;languages;;correct;;debug_path.");
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Data not in good format. The format should be 1;;x1,,y1,,width,,height;;custom_words;;minimum_height;;level;;languages;;correct;;debug_path\r\n"}];
            return nil;
        }

        VNRequestTextRecognitionLevel level = VNRequestTextRecognitionLevelAccurate;

        NSString* rectData = data[1]; // rect
        NSString* customWordsData = data[2];
        float minimumHeight = [data[3] floatValue];
        int levelData = [data[4] intValue];
        NSString* languagesData = data[5];
        BOOL correct = [data[6] boolValue];
        NSString* debugPath = data[7];

        // parse rect part
        NSArray *rect = [rectData componentsSeparatedByString:@",,"];
        if ([rect count] < 4)
        {
            NSLog(@"com.zjx.springboard: Rect data not in good format. The format should be x1,,y1,,width,,height");
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Rect data not in good format. The format should be x1,,y1,,width,,height\r\n"}];
            return nil;
        }
    
        CGRect recognizeRect = CGRectMake([rect[0] floatValue], [rect[1] floatValue], [rect[2] floatValue], [rect[3] floatValue]);
        // parse customwords part
        NSArray *customWords = [customWordsData componentsSeparatedByString:@",,"];

        // parse minimum_height part
        if (minimumHeight <= 0)
        {
            minimumHeight = 1/32;
        }

        // parse level
        if (levelData == 1)
        {
            level = VNRequestTextRecognitionLevelFast;
        }
        // parse languages part
        NSArray *languages = [languagesData componentsSeparatedByString:@",,"];

        // screen shot
        CGImageRef screenshot = [Screen createScreenShotCGImageRef];

        int orientation = [Screen getScreenOrientation];

        // init
        VKOcrManager* ocrManager = [[VKOcrManager alloc] initWithCGImage:screenshot area:recognizeRect orientation:orientation];

        // set properties
        if ([customWords count] > 1 || ![customWords[0] isEqualToString:@""])
        {
            NSLog(@"com.zjx.springboard: custom words set. Count: %d", [customWords count]);
            [ocrManager setCustomWords:customWords];
        }
        [ocrManager setMinimumHeight:minimumHeight];
        [ocrManager setRecognitionLevel:level];
        if ([languages count] > 1 || ![languages[0] isEqualToString:@""])
        {
            NSLog(@"com.zjx.springboard: languages set.");
            [ocrManager setLanguages:languages];
        }
        [ocrManager setCorrection:correct];

        NSString* result = [ocrManager recognize:error];

        if (debugPath && ![debugPath isEqualToString:@""])
        {
            [ocrManager outputDebugImage:debugPath error:error];
        }

        CFRelease(screenshot);
        
        return result;
    }
    else if (task == TASK_GET_SUPPORTED_LANGUAGE_LIST)
    {
        if ([data count] < 2)
        {
            NSLog(@"com.zjx.springboard: Data not in good format. The format should be 2;;level data:%@", data);
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Data not in good format. The format should be 2;;level\r\n"}];
            return nil;
        }
        VNRequestTextRecognitionLevel level = VNRequestTextRecognitionLevelAccurate;

        int levelData = [data[1] intValue];
        if (levelData == 1)
        {
            level = VNRequestTextRecognitionLevelFast;
        }

        NSArray *supportedLanguage;
        if (SYSTEM_VERSION_LESS_THAN(@"14.0"))
        {
            supportedLanguage = [VNRecognizeTextRequest supportedRecognitionLanguagesForTextRecognitionLevel:level revision:1 error:error];
        }
        else
        {
            supportedLanguage = [VNRecognizeTextRequest supportedRecognitionLanguagesForTextRecognitionLevel:level revision:2 error:error];
        }

        return [supportedLanguage componentsJoinedByString:@";;"];
    }
    else 
    {
        NSLog(@"com.zjx.springboard: Text recognition unknown task type");
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:@"-1;;Text recognition unknown task type\r\n"}];
        return nil;
    }
}