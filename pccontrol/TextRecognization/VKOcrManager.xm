#import "VKOcrManager.h"
#import "../Screen.h"
#include "../Common.h"


@implementation VKOcrManager
{
    BOOL inProgress;

    VNRequest* requestResult;
    NSError* errorResult;

    VNImageRequestHandler* requestHandler;
    VNRecognizeTextRequest* request;

    CIImage *img;
    CGRect recognizeRect;
}


- (id)initWithCIImage:(CIImage*)image area:(CGRect)aarea orientation:(int)orientation {
    self = [super init];
    if (self)
    {
        int after = kCGImagePropertyOrientationUp;
        if (orientation == 4)
        {
            after = kCGImagePropertyOrientationRight;
        }
        else if (orientation == 3)
        {
            after = kCGImagePropertyOrientationLeft;
        }
        else if (orientation == 2)
        {
            after = kCGImagePropertyOrientationDown;
        }

        image = [image imageByApplyingOrientation:after];
        
        img = image;

        CGFloat imageWidth = image.extent.size.width;
        CGFloat imageHeight = image.extent.size.height;



        // check whether width/height is too large
        if (aarea.size.width + aarea.origin.x > imageWidth)
        {
            aarea.size.width = imageWidth - aarea.origin.x;
        }
        if (aarea.size.height + aarea.origin.y > imageHeight)
        {
            aarea.size.height = imageHeight - aarea.origin.y;
        }
        if (aarea.size.width == 0)
        {
            aarea.size.width = imageWidth - aarea.origin.x;
        }
        if (aarea.size.height == 0)
        {
            aarea.size.height = imageHeight - aarea.origin.y;
        }

        recognizeRect = aarea;

        if (aarea.origin.x != 0 || aarea.origin.y != 0 || aarea.size.width != 0 || aarea.size.height != 0)
        {
            CGFloat y = imageHeight - aarea.origin.y - aarea.size.height;
            requestHandler = [[VNImageRequestHandler alloc] initWithCIImage:[image imageByCroppingToRect:CGRectMake(aarea.origin.x, y, aarea.size.width, aarea.size.height)] options:nil];
        }
        else
        {
            requestHandler = [[VNImageRequestHandler alloc] initWithCIImage:image options:nil];
        }

        request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error){
            requestResult = request;
            errorResult = error;
        }];

        // may cause crash
        if (SYSTEM_VERSION_LESS_THAN(@"14.0"))
        {
            request.revision = 1;
        }
        else
        {
            request.revision = 2;
        }
    }
    return self;
}

- (id)initWithImagePath:(NSString*)path area:(CGRect)aarea orientation:(int)orientation {
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    CIImage *image = [CIImage imageWithContentsOfURL:fileURL];
    return [self initWithCIImage:image area:aarea orientation:orientation];
}

/*
Return the string from a area
*/
- (NSString*)recognize:(NSError**)error{
    if (inProgress)
    {
        NSLog(@"com.zjx.springboard: cannot start recognize text from this instance: %@ because another task is running.", self);
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Cannot start recognize text from this instance: %@ because another task is running.\r\n", self]}];
        return nil;
    }
    inProgress = true;

    NSError *err = nil;
    [requestHandler performRequests:@[request] error:&err];

    if (err)
    {
        NSLog(@"com.zjx.springboard: error happened while performing ocr. %@", err);
        *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Error happened while performing ocr. Error: %@\r\n", err]}];
        return nil;
    }
    
    NSMutableArray<NSString*>* stringList = [[NSMutableArray alloc] init];

    for (VNRecognizedTextObservation* i in requestResult.results)
    {
        [stringList addObject:[[i topCandidates:1][0] string]];
    }

    inProgress = false;
    return [stringList componentsJoinedByString:@";;"];
}

/*
Return area that contain text
*/
- (NSArray*)areasOfText {

}

- (void)outputDebugImage:(NSString*)imagePath error:(NSError**)error{
    inProgress = true;

    NSError* err = nil;
    UIImage* test = [self drawDebugOutputfromArray:requestResult.results error:&err];

    if (err)
    {
        NSLog(@"com.zjx.springboard: error while outputing debug image.");
        return;
    }

    [[NSFileManager defaultManager] createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];

    [UIImageJPEGRepresentation(test, 0.7) writeToFile:imagePath atomically:true];
    inProgress = false;

    //[test writeJPEGRepresentationOfImage];
}

- (void)drawRectangle:(CGRect)rect inContext:(CGContextRef)ctx withColor:(UIColor*)color {
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;

    CGPoint topLeft = rect.origin;
    CGPoint topRight = CGPointMake(x + width, y);
    CGPoint bottomLeft = CGPointMake(x, y + height);
    CGPoint bottomRight = CGPointMake(x + width, y + height);

    CGContextSetStrokeColorWithColor(ctx, color.CGColor);

    CGContextMoveToPoint(ctx, topLeft.x, topLeft.y);
    CGContextAddLineToPoint(ctx, topRight.x, topRight.y);
    CGContextAddLineToPoint(ctx, bottomRight.x, bottomRight.y);
    CGContextAddLineToPoint(ctx, bottomLeft.x, bottomLeft.y);
    CGContextAddLineToPoint(ctx, topLeft.x, topLeft.y);

    CGContextDrawPath(ctx, kCGPathStroke);
}


-(UIImage *)drawDebugOutputfromArray:(NSArray<VNRecognizedTextObservation*>*)arr error:(NSError**)error{
    // reformat rect (don't know why there is size differnt here)
    CGFloat scale = [Screen getScale];
    CGRect screenBounds = [Screen getBounds];

    UIImage* image = [[UIImage alloc] initWithCIImage:img];
    
    CGFloat imageAbsoluteWidth = image.size.width;
    CGFloat imageAbsoluteHeight = image.size.height;

    CGRect wholeImageRect = CGRectMake(0, 0, imageAbsoluteWidth, imageAbsoluteHeight);

    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0); // CGSizeMake(imageAbsoluteWidth, imageAbsoluteHeight)
 
	// draw original image into the context
	[image drawInRect:wholeImageRect];
 
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
 
    // draw match rectangle
    [self drawRectangle:recognizeRect inContext:ctx withColor:[UIColor redColor]];

    [[UIColor redColor] setFill]; // set color
    [[NSString stringWithFormat:@"Rect:(%d, %d, %d, %d)", (int)recognizeRect.origin.x, (int)recognizeRect.origin.y, (int)recognizeRect.size.width, (int)recognizeRect.size.height] drawInRect:CGRectIntegral(recognizeRect) withFont:[UIFont boldSystemFontOfSize:30]]; 

    for (VNRecognizedTextObservation* i in arr)
    {
        VNRecognizedText* text = [i topCandidates:1][0];
        NSString* textString = [text string];
            
        NSError *err = nil;
        VNRectangleObservation* boundingBox = [text boundingBoxForRange:NSMakeRange(0, [textString length]) error:&err];

        if (err)
        {
            NSLog(@"com.zjx.springboard: unable to output debug image for text recognization. Error: %@", err);
            *error = [NSError errorWithDomain:@"com.zjx.zxtouchsp" code:999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"-1;;Unable to output debug image for text recognization. Error: %@", err]}];
            return nil;
        }

        //test = [self drawTextRectangle:CGRectMake(100, 100, 100, 100) andText:@"test"];

        float rectWidth = (boundingBox.topRight.x - boundingBox.topLeft.x) * recognizeRect.size.width;
        float rectHeight = abs(boundingBox.topLeft.y - boundingBox.bottomLeft.y) * recognizeRect.size.height;
        float rectx = boundingBox.topLeft.x * recognizeRect.size.width + recognizeRect.origin.x;
        float recty = (1 - boundingBox.topLeft.y) * recognizeRect.size.height + recognizeRect.origin.y;

        CGRect rect = CGRectMake(rectx, recty, rectWidth, rectHeight);
        //NSLog(@"com.zjx.springboard: rect: recognizeRect: %f, boundingBox: %f", recognizeRect.origin.y, boundingBox.topLeft.y);
        // draw text rectangles
        [self drawRectangle:rect inContext:ctx withColor:[UIColor greenColor]];
        
        // draw filled rectangle
        CGContextSetFillColorWithColor(ctx, [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor); // set color
        CGContextFillRect(ctx, rect);

        // draw text
        [[UIColor redColor] setFill]; // set color
        UIFont *font = [UIFont boldSystemFontOfSize:20]; //set font size
        rect.origin.y = rect.origin.y + rect.size.height; // draw
        [textString drawInRect:CGRectIntegral(rect) withFont:font]; 

        //NSLog(@"com.zjx.springboard: string: %@, topLeft: %f, topright:%f", textString, boundingBox.topLeft.x, boundingBox.topRight.x);

    }


 
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
 
	// free the context
	UIGraphicsEndImageContext();

	return retImage;
}


- (void)setMinimumHeight:(float)height {
    request.minimumTextHeight = height;
}

- (void)setCustomWords:(NSArray*)customWords {
    request.customWords = customWords;
}

- (void)setRecognitionLevel:(VNRequestTextRecognitionLevel)level {
    request.recognitionLevel = level;
}

- (void)setLanguages:(NSArray*)languages {
    request.recognitionLanguages = languages;
}

- (void)setCorrection:(BOOL)correct {
    request.usesLanguageCorrection = correct;
}


@end