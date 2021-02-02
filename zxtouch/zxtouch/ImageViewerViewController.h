//
//  ImageViewerViewController.h
//  zxtouch
//
//  Created by Jason on 2021/2/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageViewerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *path;

@end

NS_ASSUME_NONNULL_END
