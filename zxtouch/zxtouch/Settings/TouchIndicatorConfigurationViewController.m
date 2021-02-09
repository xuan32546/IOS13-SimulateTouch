//
//  TouchIndicatorConfigurationViewController.m
//  zxtouch
//
//  Created by Jason on 2021/1/19.
//

#import "TouchIndicatorConfigurationViewController.h"
#import "TableViewCellWithSwitch.h"
#import "TableViewCellWithSlider.h"
#import "Config.h"
#import "Util.h"
#import "Socket.h"

@interface TouchIndicatorConfigurationViewController ()

@end

@implementation TouchIndicatorConfigurationViewController
{
    NSArray *colorStrs;
    NSArray *colors;
    BOOL isShowing;
    NSMutableDictionary *config;
    Socket *springBoardSocket;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"touchIndicator", nil);
    
    colorStrs = @[@"Red", @"Blue", @"Green", @"White", @"Black", @"Orange", @"Yellow"];
    colors = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor], [UIColor whiteColor], [UIColor blackColor], [UIColor orangeColor], [UIColor yellowColor]];
    
    UINib *SwitchCellNib = [UINib nibWithNibName:@"TableViewCellWithSwitch" bundle:nil];
    [_tableView registerNib:SwitchCellNib forCellReuseIdentifier:@"SwitchCell"];
    
    UINib *sliderCellNib = [UINib nibWithNibName:@"TableViewCellWithSlider" bundle:nil];
    [_tableView registerNib:sliderCellNib forCellReuseIdentifier:@"SliderCell"];
    
    // change plist
    if (![[NSFileManager defaultManager] fileExistsAtPath:SPRINGBOARD_CONFIG_PATH])
    {
        config = [[NSMutableDictionary alloc] initWithDictionary:@{@"touch_indicator":@{@"show": @(0), @"color":@{@"alpha": @(0.7), @"r": @(255), @"g": @(0), @"b": @(0)}}}];
        [config writeToFile:SPRINGBOARD_CONFIG_PATH atomically:NO];
    }

    config = [[NSMutableDictionary alloc] initWithContentsOfFile:SPRINGBOARD_CONFIG_PATH];
    
    isShowing = [config[@"touch_indicator"][@"show"] boolValue];
    
    springBoardSocket = [[Socket alloc] init];
    [springBoardSocket connect:@"127.0.0.1" byPort:6000];
}

- (void)alphaValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    float interval = 0.1f;//set this
    [slider setValue:interval*floorf((slider.value/interval)+0.5f) animated:NO];
    
    if (!config)
    {
        [Util showAlertBoxWithOneOption:self title:@"Error" message:@"Error. Configuration file does not exist. Please go to \"settings - fix configuration\" to fix this problem." buttonString:@"OK"];
        return;
    }
    
    config[@"touch_indicator"][@"color"][@"alpha"] = @(slider.value);
    
    [config writeToFile:SPRINGBOARD_CONFIG_PATH atomically:NO];
    
    
    [springBoardSocket send:@"262\r\n"];
}

- (void)switchTouchIndicatorStatus:(id)sender {
    UISwitch *s = (UISwitch*)sender;

    if (!config)
    {
        [Util showAlertBoxWithOneOption:self title:@"Error" message:@"Error. Configuration file does not exist. Please go to \"settings - fix configuration\" to fix this problem." buttonString:@"OK"];
    }
    
    // restart touch indicator if touch indicator is on
    if ([s isOn])
    {
        if (config)
            config[@"touch_indicator"][@"show"] = @(true);
        
        // turn on
        [springBoardSocket send:@"261\r\n"];
        
        isShowing = true;
    }
    else
    {
        if (config)
            config[@"touch_indicator"][@"show"] = @(false);

        // turn off
        [springBoardSocket send:@"260\r\n"];
        
        isShowing = false;
    }

    if (![config writeToFile:SPRINGBOARD_CONFIG_PATH atomically:NO])
    {
        [Util showAlertBoxWithOneOption:self title:@"Error" message:@"Although success, the configuration file cannot be written." buttonString:@"OK"];
    }
     
}

//配置每个section(段）有多少row（行） cell
//默认只有一个section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!config)
    {
        return 1;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//每行显示什么东西
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *result;
    
    if (!config)
    {
        [Util showAlertBoxWithOneOption:self title:@"Error" message:@"Error. Configuration file does not exist. Please go to \"settings - fix configuration\" to fix this problem." buttonString:@"OK"];
    }
    
    if (indexPath.row == 0)
    {
        static NSString *cellID = @"SwitchCell";

        TableViewCellWithSwitch *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            NSLog(@"create a setting cell switch");
            cell = [[TableViewCellWithSwitch alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        [cell setTitleText:NSLocalizedString(@"touchIndicator", nil)];

        [cell.switchBtn addTarget:self action:@selector(switchTouchIndicatorStatus:) forControlEvents:UIControlEventValueChanged];
        
        if ([config[@"touch_indicator"][@"show"] boolValue])
        {
            [cell.switchBtn setOn:YES];
        }
        else
        {
            [cell.switchBtn setOn:NO];
        }
        
        result = cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *cellID = @"SliderCell";

        TableViewCellWithSlider *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        //判断队列里面是否有这个cell 没有自己创建，有直接使用
        if (cell == nil) {
            //没有,创建一个
            NSLog(@"create a setting cell switch");
            cell = [[TableViewCellWithSlider alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.title.text = NSLocalizedString(@"alpha", nil);
        cell.slideBar.maximumValue = 1.0f;
        cell.slideBar.minimumValue = 0.0f;
        cell.slideBar.continuous = YES;
        [cell.slideBar addTarget:self
              action:@selector(alphaValueChanged:)
              forControlEvents:UIControlEventValueChanged];
        
        cell.slideBar.value = [config[@"touch_indicator"][@"color"][@"alpha"] floatValue];
        cell.value.text = [NSString stringWithFormat:@"%.1f", cell.slideBar.value];

        result = cell;
    }
    result.selectionStyle = UITableViewCellSelectionStyleNone;

    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
     return 1;  // Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component {
     return colors.count;//Or, return as suitable for you...normally we use array for dynamic
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     return colorStrs[row];//Or, your suitable title; like Choice-a, etc.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // write to configuration file

    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;

    [colors[row] getRed:&red green:&green blue:&blue alpha:&alpha];

    config[@"touch_indicator"][@"color"][@"r"] = @(red*255);
    config[@"touch_indicator"][@"color"][@"g"] = @(green*255);
    config[@"touch_indicator"][@"color"][@"b"] = @(blue*255);
        
    if (![config writeToFile:SPRINGBOARD_CONFIG_PATH atomically:NO])
    {
        [Util showAlertBoxWithOneOption:self title:@"Error" message:@"Cannot set color. Unable to write configuration file" buttonString:@"OK"];
        return;
    }

    
    // restart touch indicator if touch indicator is on
    if (isShowing)
    {
        [springBoardSocket send:@"262\r\n"]; // reload config
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   return NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
