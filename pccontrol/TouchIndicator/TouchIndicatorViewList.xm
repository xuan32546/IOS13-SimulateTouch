#import "TouchIndicatorViewList.h"

#define DEFAULT_INIT_SIZE 6
#define MAX_TOUCH_INDEX 20

@implementation TouchIndicatorViewList
{
    NSMutableArray<TouchIndicatorView*> *indicatrorViewArr; // use index as indicator id
    int indicatorIdToTouchIndex[MAX_TOUCH_INDEX];
    int touchIndexToIndicatorId[MAX_TOUCH_INDEX];
    int indicatorCount;
}

/*
- (id)init {
    self = [super init];
    if (self)
    {
        indicatrorViewArr = [NSMutableArray new];
        indicatorCount = 0;
        // init the index array to all "UNUSE" flag
        for (int i = 0; i < MAX_TOUCH_INDEX; i++)
        {
            touchIndexToIndicatorId[i] = -1;
            indicatorIdToTouchIndex[i] = -1;
        }

        // append 6 touch indicator view to the list
        for (int i = 0; i < DEFAULT_INIT_SIZE; i++)
        {
            TouchIndicatorView *indicator = [[TouchIndicatorView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_VIEW_DEFAULT_SIZE, INDICATOR_VIEW_DEFAULT_SIZE)];
            indicator.layer.cornerRadius = INDICATOR_VIEW_DEFAULT_SIZE/2;
            [indicatrorViewArr addObject:indicator];
        }

    }
    return self;
}

- (int)count {
    return [indicatrorViewArr count];
}

- (TouchIndicatorView*)get:(int)index {
    return indicatrorViewArr[index];
}

// if a new subview is needed
- (UIView*)touchDown:(int)fingerIndex atX:(int)x andY:(int)y {
    // search array for unused indicator
    for (int i = 0; i < indicatorCount; i++)
    {
        if (indicatorIdToTouchIndex[i] == -1)
        {
            indicatorIdToTouchIndex[i] = fingerIndex;
            touchIndexToIndicatorId[fingerIndex] = i;
        }
        else // add a subview
        {
            TouchIndicatorView *indicator = [[TouchIndicatorView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_VIEW_DEFAULT_SIZE, INDICATOR_VIEW_DEFAULT_SIZE)];
            indicator.layer.cornerRadius = INDICATOR_VIEW_DEFAULT_SIZE/2;
            [indicatrorViewArr addObject:indicator];
        }
    }
}

// return false if not found
- (BOOL)moveFinger:(int)fingerIndex toX:(CGFloat)x andY:(CGFloat)y {
    // search for finger index
    int index = indicatorIdToTouchIndex[fingerIndex];

    for (TouchIndicatorView* indicator in indicatrorViewArr) 
    {
        if (indicator.fingerIndex == fingerIndex)
        {
            
        }
    }

    return false;
}

 - (BOOL)showTouchIndictorByFingerIndex:(int)fingerIndex {

 }
*/
@end