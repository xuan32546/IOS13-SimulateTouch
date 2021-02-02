#ifndef TOUCH_INDICATOR_COORDINATE_VIEW_H
#define TOUCH_INDICATOR_COORDINATE_VIEW_H

// make it constant here but will be changed in future versions
#define INDICATOR_VIEW_DEFAULT_SIZE 60 // including width and height because it is a circle 
#define SIZE_INDIACTOR_TOUCH_RADIUS_RATIO 1590 // (size of indicator)/(major radius)

#endif

@interface TouchIndicatorCoordinateView : UIView
@property (weak, nonatomic) UILabel* coordinateLabel;


-(void)dealloc;

@end