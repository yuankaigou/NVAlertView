//
//  ViewController.m
//  NVAlertUsage
//
//  Created by gougou on 2017/6/5.
//  Copyright © 2017年 yuankaigou. All rights reserved.
//

#import "ViewController.h"

#import "NVAlertView.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray <NSArray *>*dataArray;

@end


NSString *kSuccessTitle = @"Congratulations";
NSString *kErrorTitle = @"Connection error";
NSString *kNoticeTitle = @"Notice";
NSString *kWarningTitle = @"Warning";
NSString *kInfoTitle = @"Info";
NSString *kSubtitle = @"出现这个框框说明你有问题了";
NSString *kButtonTitle = @"Done";
NSString *kAttributeTitle = @"Attributed string operation successfully completed.";

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSArray *dataArray = @[@[@"1-Question类型", @"2-Success类型", @"3-Notice类型", @"4-Warning类型", @"5-Info类型", @"6-Edit类型", @"7-自定义类型图标", @"8-还可以添加图片"] ,@[@"1-基础提示-按钮在下边", @"2-只包含图片", @"3-含有标题等信息"]];
    self.dataArray = dataArray;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray[section].count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0f;
}

//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%zd", indexPath.row);
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
            {
                //问题风格
                NVAlertView *alert = [[NVAlertView alloc] init];
                
                [alert addButton:@"继续支付" actionBlock:^(void) {
                    NSLog(@"继续支付被点击");
                }];
                [alert showQuestion:self title:@"确认要离开收银台?" subTitle:@"超过支付时效后订单将被取消, 请尽快完成支付" closeButtonTitle:@"确认离开" duration:0.0f];
            }
                break;
                
                
            case 1:
            {
                //成功风格
                NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
                
                
                NVButton *button = [alert addButton:@"First Button" target:self selector:@selector(firstButton)];
                
                button.buttonFormatBlock = ^NSDictionary* (void)
                {
                    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                    
                    buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
                    buttonConfig[@"textColor"] = [UIColor blackColor];
                    buttonConfig[@"borderWidth"] = @2.0f;
                    buttonConfig[@"borderColor"] = [UIColor greenColor];
                    
                    return buttonConfig;
                };
                
                
                
                [alert addButton:@"Second Button" actionBlock:^(void) {
                    NSLog(@"Second button tapped");
                }];
                
                
                
                //alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];
                
                [alert showSuccess:kSuccessTitle subTitle:kSubtitle closeButtonTitle:kButtonTitle duration:0.0f];
            }
                break;
                
            case 2:
            {
                //notice 风格, 时间都是自己定的 没有设置就 手动按钮移除
                NVAlertView *alert = [[NVAlertView alloc] init];
                
                [alert showNotice:self title:kNoticeTitle subTitle:@"显示3秒后就会消失, 设置duration属性就可以， 不设置可以添加按钮移除视图" closeButtonTitle:@"关闭" duration:3.0f];
            }
                break;
                
            case 3:
            {
                //warnning 类型, 时间都是自己定的 没有设置就 手动按钮移除
                NVAlertView *alert = [[NVAlertView alloc] init];
                
                [alert showWarning:self title:kWarningTitle subTitle:kSubtitle closeButtonTitle:kButtonTitle duration:0.0f];
            }
                break;
                
            case 4:
            {
                //Info 类型
                NVAlertView *alert = [[NVAlertView alloc] init];
                //定时按钮
                [alert addTimerToButtonIndex:0 reverse:YES];
                [alert showInfo:self title:@"Countdown Timer"
                       subTitle:@"This alert has a duration set, and a countdown timer on the Dismiss button to show how long is left."
               closeButtonTitle:@"Dismiss" duration:10.0f];
            }
                break;
                
            case 5:
            {
                //编辑类型 类型
                NVAlertView *alert = [[NVAlertView alloc] init];
                [alert setHorizontalButtons:YES];
                
                NVTextView *evenField = [alert addTextField:@"Enter an even number"];
                evenField.keyboardType = UIKeyboardTypeNumberPad;
                
                NVTextView *oddField = [alert addTextField:@"Enter an odd number"];
                oddField.keyboardType = UIKeyboardTypeNumberPad;
                
                [alert addButton:@"Test Validation" validationBlock:^BOOL{
                    if (evenField.text.length == 0)
                    {
                        [[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You forgot to add an even number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [evenField becomeFirstResponder];
                        return NO;
                    }
                    
                    if (oddField.text.length == 0)
                    {
                        [[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You forgot to add an odd number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [oddField becomeFirstResponder];
                        return NO;
                    }
                    
                    NSInteger evenFieldEntry = (evenField.text).integerValue;
                    BOOL evenFieldPassedValidation = evenFieldEntry % 2 == 0;
                    
                    if (!evenFieldPassedValidation)
                    {
                        [[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"That is not an even number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [evenField becomeFirstResponder];
                        return NO;
                    }
                    
                    NSInteger oddFieldEntry = (oddField.text).integerValue;
                    BOOL oddFieldPassedValidation = oddFieldEntry % 2 == 1;
                    
                    if (!oddFieldPassedValidation)
                    {
                        [[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"That is not an odd number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [oddField becomeFirstResponder];
                        return NO;
                    }
                    return YES;
                } actionBlock:^{
                    [[[UIAlertView alloc] initWithTitle:@"Great Job!" message:@"Thanks for playing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
                
                [alert showEdit:self title:@"Validation" subTitle:@"Ensure the data is correct before dismissing!" closeButtonTitle:@"Cancel" duration:0];
            }
                break;
                
            case 6:
            {
                //git - 自定义类型图表
                NVAlertView *alert = [[NVAlertView alloc] init];
                
                UIColor *color = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
                
                //添加自定义类型的图片
                [alert showCustom:self image:[UIImage imageNamed:@"git"] color:color title:@"Custom" subTitle:@"Add a custom icon and color for your own type of alert!" closeButtonTitle:@"OK" duration:0.0f];
                
            }
                break;
                
            case 7:
            {
                NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(0, 0, 240 - 24, 96);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = [UIImage imageNamed:@"qqImage.png"];
                [alert addCustomView:imageView];
                
                NVButton *button = [alert addButton:@"马上设置" target:self selector:@selector(firstButton)];
                button.buttonFormatBlock = ^NSDictionary* (void)
                {
                    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                    buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:30/255.0f green:185/255.0f blue:242/255.0f alpha:1];
                    return buttonConfig;
                };
                
                [alert showSuccess:nil subTitle:nil closeButtonTitle:@"关闭" duration:0];
                
            }
                break;
                
                
            default:
                break;
        }
        
    } else {
        
        switch (indexPath.row) {
            case 0:
            {
                //按钮下方基础风格
                NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(0, 0, 240 - 24, 96);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = [UIImage imageNamed:@"qqImage.png"];
                [alert addCustomView:imageView];
                
                NVButton *button = [alert addButton:@"马上设置" target:self selector:@selector(firstButton)];
                button.buttonFormatBlock = ^NSDictionary* (void)
                {
                    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                    buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:30/255.0f green:185/255.0f blue:242/255.0f alpha:1];
                    return buttonConfig;
                };
                
                [alert showCloseButton:self title:nil subTitle:nil duration:0];
            }
                break;
                
            case 1:
            {
                NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(0, 0, 240 - 24, 96);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = [UIImage imageNamed:@"qqImage.png"];
                [alert addCustomView:imageView];
                [alert showCloseButton:self title:nil subTitle:nil duration:0];
            }
                break;
                
            case 2:
            {
                NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(0, 0, 240 - 24, 96);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = [UIImage imageNamed:@"qqImage.png"];
                [alert addCustomView:imageView];
                
                NVButton *button = [alert addButton:@"马上设置" target:self selector:@selector(firstButton)];
                button.buttonFormatBlock = ^NSDictionary* (void)
                {
                    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                    buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:30/255.0f green:185/255.0f blue:242/255.0f alpha:1];
                    return buttonConfig;
                };
                [alert showCloseButton:self title:@"开启消息推送" subTitle:@"即时接收好友消息, 不再错过任何精彩" duration:0];
            }
                break;
                
            default:
                break;
        }
    }
    
}




#pragma makr - 按钮点击


#pragma mark - OnePattern

- (void)gykOnlyPic{
    
    NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 240 - 24, 96);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"qqImage.png"];
    [alert addCustomView:imageView];
    
    NVButton *button = [alert addButton:@"马上设置" target:self selector:@selector(firstButton)];
    button.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:30/255.0f green:185/255.0f blue:242/255.0f alpha:1];
        return buttonConfig;
    };
    
    [alert showCloseButton:self title:nil subTitle:nil duration:0];
}

- (void)gykPattern{
    NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];
    //加入自定义图片
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 240 - 24, 96);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"qqImage.png"];
    [alert addCustomView:imageView];
    
    NVButton *button = [alert addButton:@"马上设置" target:self selector:@selector(firstButton)];
    button.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:30/255.0f green:185/255.0f blue:242/255.0f alpha:1];
        return buttonConfig;
    };
    
    [alert showCloseButton:self title:@"开启消息推送" subTitle:@"及时接受好友消息, 不再错过任何精彩。" duration:0];
}

- (void)firstButton{
    NSLog(@"firstButton Click");
}



@end
