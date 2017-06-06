# NVAlertView


基于NVAlerView的修改, 增加了目前流行的常规样式。


## ScreenShots

* 顶部关闭按钮样式

![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.32.png)

![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.32.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.28.png)

![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.22.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.29.53.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.29.53.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.16.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.07.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.29.58.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.30.02.png)
![](/Users/gougou/Desktop/Simulator Screen Shot 2017年6月6日 下午8.29.47.png)


## 基本接口调用

### Fluent style

```Objective-C

NVAlertViewBuilder *builder = [NVAlertViewBuilder new]
.addButtonWithActionBlock(@"Send", ^{ /*work here*/ });
NVAlertViewShowBuilder *showBuilder = [NVAlertViewShowBuilder new]
.style(NVAlertViewStyleWarning)
.title(@"Title")
.subTitle(@"Subtitle")
.duration(0);
[showBuilder showAlertView:builder.alertView onViewController:self.window.rootViewController];
// or even
showBuilder.show(builder.alertView, self.window.rootViewController);
```

#### Complex
```Objective-C
    NSString *title = @"Title";
    NSString *message = @"Message";
    NSString *cancel = @"Cancel";
    NSString *done = @"Done";
    
    NVALertViewTextFieldBuilder *textField = [NVALertViewTextFieldBuilder new].title(@"Code");
    NVALertViewButtonBuilder *doneButton = [NVALertViewButtonBuilder new].title(done)
    .validationBlock(^BOOL{
        NSString *code = [textField.textField.text copy];
        return [code isVisible];
    })
    .actionBlock(^{
        NSString *code = [textField.textField.text copy];
        [self confirmPhoneNumberWithCode:code];
    });
    
    NVAlertViewBuilder *builder = [NVAlertViewBuilder new]
    .showAnimationType(NVAlertViewShowAnimationFadeIn)
    .hideAnimationType(NVAlertViewHideAnimationFadeOut)
    .shouldDismissOnTapOutside(NO)
    .addTextFieldWithBuilder(textField)
    .addButtonWithBuilder(doneButton);
    
    NVAlertViewShowBuilder *showBuilder = [NVAlertViewShowBuilder new]
    .style(NVAlertViewStyleCustom)
    .image([NVAlertViewStyleKit imageOfInfo])
    .color([UIColor blueColor])
    .title(title)
    .subTitle(message)
    .closeButtonTitle(cancel)
    .duration(0.0f);

    [showBuilder showAlertView:builder.alertView onViewController:self];
```

### Easy to use
```Objective-C
// Get started
NVAlertView *alert = [[NVAlertView alloc] init];

[alert showSuccess:self title:@"Hello World" subTitle:@"This is a more descriptive text." closeButtonTitle:@"Done" duration:0.0f];

// Alternative alert types
[alert showError:self title:@"Hello Error" subTitle:@"This is a more descriptive error text." closeButtonTitle:@"OK" duration:0.0f]; // Error
[alert showNotice:self title:@"Hello Notice" subTitle:@"This is a more descriptive notice text." closeButtonTitle:@"Done" duration:0.0f]; // Notice
[alert showWarning:self title:@"Hello Warning" subTitle:@"This is a more descriptive warning text." closeButtonTitle:@"Done" duration:0.0f]; // Warning
[alert showInfo:self title:@"Hello Info" subTitle:@"This is a more descriptive info text." closeButtonTitle:@"Done" duration:0.0f]; // Info
[alert showEdit:self title:@"Hello Edit" subTitle:@"This is a more descriptive info text with a edit textbox" closeButtonTitle:@"Done" duration:0.0f]; // Edit
[alert showCustom:self image:[UIImage imageNamed:@"git"] color:color title:@"Custom" subTitle:@"Add a custom icon and color for your own type of alert!" closeButtonTitle:@"OK" duration:0.0f]; // Custom
[alert showWaiting:self title:@"Waiting..." subTitle:@"Blah de blah de blah, blah. Blah de blah de" closeButtonTitle:nil duration:5.0f];
[alert showQuestion:self title:@"Question?" subTitle:kSubtitle closeButtonTitle:@"Dismiss" duration:0.0f];


// Using custom alert width
NVAlertView *alert = [[NVAlertView alloc] initWithWindowWidth:300.0f];
```

### NVAlertview in a new window. (No UIViewController)
```Objective-C

NVAlertView *alert = [[NVAlertView alloc] initWithNewWindow];

[alert showSuccess:@"Hello World" subTitle:@"This is a more descriptive text." closeButtonTitle:@"Done" duration:0.0f];

// Alternative alert types
[alert showError:@"Hello Error" subTitle:@"This is a more descriptive error text." closeButtonTitle:@"OK" duration:0.0f]; // Error
[alert showNotice:@"Hello Notice" subTitle:@"This is a more descriptive notice text." closeButtonTitle:@"Done" duration:0.0f]; // Notice
[alert showWarning:@"Hello Warning" subTitle:@"This is a more descriptive warning text." closeButtonTitle:@"Done" duration:0.0f]; // Warning
[alert showInfo:@"Hello Info" subTitle:@"This is a more descriptive info text." closeButtonTitle:@"Done" duration:0.0f]; // Info
[alert showEdit:@"Hello Edit" subTitle:@"This is a more descriptive info text with a edit textbox" closeButtonTitle:@"Done" duration:0.0f]; // Edit
[alert showCustom:[UIImage imageNamed:@"git"] color:color title:@"Custom" subTitle:@"Add a custom icon and color for your own type of alert!" closeButtonTitle:@"OK" duration:0.0f]; // Custom
[alert showWaiting:@"Waiting..." subTitle:@"Blah de blah de blah, blah. Blah de blah de" closeButtonTitle:nil duration:5.0f];
[alert showQuestion:@"Question?" subTitle:kSubtitle closeButtonTitle:@"Dismiss" duration:0.0f];

// Using custom alert width
NVAlertView *alert = [[NVAlertView alloc] initWithNewWindowWidth:300.0f];
```

### New Window: Known issues

1. NVAlert animation is wrong in landscape. (iOS 6.X and 7.X)

### 添加按钮
```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];

//Using Selector
[alert addButton:@"First Button" target:self selector:@selector(firstButton)];

//Using Block
[alert addButton:@"Second Button" actionBlock:^(void) {
    NSLog(@"Second button tapped");
}];

//Using Blocks With Validation
[alert addButton:@"Validate" validationBlock:^BOOL {
    BOOL passedValidation = ....
    return passedValidation;

} actionBlock:^{
    // handle successful validation here
}];

[alert showSuccess:self title:@"Button View" subTitle:@"This alert view has buttons" closeButtonTitle:@"Done" duration:0.0f];
```

### 下方关闭按钮样式调用

```Objective-C
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

```


### 定时进度按钮添加
```Objective-C
//The index of the button to add the timer display to.
[alert addTimerToButtonIndex:0 reverse:NO];
```

Example:

```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];
[alert addTimerToButtonIndex:0 reverse:YES];
[alert showInfo:self title:@"Countdown Timer" subTitle:@"This alert has a duration set, and a countdown timer on the Dismiss button to show how long is left." closeButtonTitle:@"Dismiss" duration:10.0f];
```


### 文本属性设置
```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];

alert.attributedFormatBlock = ^NSAttributedString* (NSString *value)
{
    NSMutableAttributedString *subTitle = [[NSMutableAttributedString alloc]initWithString:value];

    NSRange redRange = [value rangeOfString:@"Attributed" options:NSCaseInsensitiveSearch];
    [subTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:redRange];

    NSRange greenRange = [value rangeOfString:@"successfully" options:NSCaseInsensitiveSearch];
    [subTitle addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:greenRange];

    NSRange underline = [value rangeOfString:@"completed" options:NSCaseInsensitiveSearch];
    [subTitle addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:underline];

    return subTitle;
};

[alert showSuccess:self title:@"Button View" subTitle:@"Attributed string operation successfully completed." closeButtonTitle:@"Done" duration:0.0f];
```

### 添加文本输入框
```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];

UITextField *textField = [alert addTextField:@"Enter your name"];

[alert addButton:@"Show Name" actionBlock:^(void) {
    NSLog(@"Text value: %@", textField.text);
}];
NV
[alert showEdit:self title:@"Edit View" subTitle:@"This alert view shows a text box" closeButtonTitle:@"Done" duration:0.0f];
```

### 进度
```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];
    
[alert showWaiting:self title:@"Waiting..." subTitle:@"Blah de blah de blah, blah. Blah de blah de" closeButtonTitle:nil duration:5.0f];
```

### 添加switch按钮
```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];
    
NVSwitchView *switchView = [alert addSwitchViewWithLabel:@"Don't show again".uppercaseString];
switchView.tintColor = [UIColor brownColor];
    
[alert addButton:@"Done" actionBlock:^(void) {
    NSLog(@"Show again? %@", switchView.isSelected ? @"-No": @"-Yes");
}];
    
[alert showCustom:self image:[UIImage imageNamed:@"switch"] color:[UIColor brownColor] title:kInfoTitle subTitle:kSubtitle closeButtonTitle:nil duration:0.0f];
```

### 添加自定义视图(比如:pin码输入框,imageView等视图)
```Objective-C
NVAlertView *alert = [[NVAlertView alloc] init];

UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 215.0f, 80.0f)];
customView.backgroundColor = [UIColor redColor];

[alert addCustomView:customView];

[alert showNotice:self title:@"Title" subTitle:@"This alert view shows a custom view" closeButtonTitle:@"Done" duration:0.0f];
```

### NVAlertView属性
```Objective-C
//Dismiss on tap outside (Default is NO)
alert.shouldDismissOnTapOutside = YES;

//Hide animation type (Default is NVAlertViewHideAnimationFadeOut)
alert.hideAnimationType = NVAlertViewHideAnimationSlideOutToBottom;

//Show animation type (Default is NVAlertViewShowAnimationSlideInFromTop)
alert.showAnimationType =  NVAlertViewShowAnimationSlideInFromLeft;

//Set background type (Default is NVAlertViewBackgroundShadow)
alert.backgroundType = NVAlertViewBackgroundBlur;

//Overwrite NVAlertView (Buttons, top circle and borders) colors
alert.customViewColor = [UIColor purpleColor];

//Set custom tint color for icon image.
alert.iconTintColor = [UIColor purpleColor];

//Override top circle tint color with background color
alert.tintTopCircle = NO;

//Set custom corner radius for NVAlertView
alert.cornerRadius = 13.0f;

//Overwrite NVAlertView background color
alert.backgroundViewColor = [UIColor cyanColor];

//Returns if the alert is visible or not.
alert.isVisible;

//Make the top circle icon larger
alert.useLargerIcon = YES;

//Using sound
alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [[NSBundle mainBundle] resourcePath]]];


```

### Helpers
```Objective-C
//Receiving information that NVAlertView is dismissed
[alert alertIsDismissed:^{
    NSLog(@"NVAlertView dismissed!");
}];
```

#### 几种类别样式(头标视图不同)
```Objective-C
typedef NS_ENUM(NSInteger, NVAlertViewStyle)
{
    NVAlertViewStyleSuccess,
    NVAlertViewStyleError,
    NVAlertViewStyleNotice,
    NVAlertViewStyleWarning,
    NVAlertViewStyleInfo,
    NVAlertViewStyleEdit,
    NVAlertViewStyleWaiting,
    NVAlertViewStyleQuestion,
    NVAlertViewStyleCustom
};
```
#### AlertView 移除动画枚举
```Objective-C
typedef NS_ENUM(NSInteger, NVAlertViewHideAnimation)
{
    NVAlertViewHideAnimationFadeOut,
    NVAlertViewHideAnimationSlideOutToBottom,
    NVAlertViewHideAnimationSlideOutToTop,
    NVAlertViewHideAnimationSlideOutToLeft,
    NVAlertViewHideAnimationSlideOutToRight,
    NVAlertViewHideAnimationSlideOutToCenter,
    NVAlertViewHideAnimationSlideOutFromCenter,
    NVAlertViewHideAnimationSimplyDisappear
};
```
#### AlertView 进入动画枚举
```Objective-C
typedef NS_ENUM(NSInteger, NVAlertViewShowAnimation)
{
    NVAlertViewShowAnimationFadeIn,
    NVAlertViewShowAnimationSlideInFromBottom,
    NVAlertViewShowAnimationSlideInFromTop,
    NVAlertViewShowAnimationSlideInFromLeft,
    NVAlertViewShowAnimationSlideInFromRight,
    NVAlertViewShowAnimationSlideInFromCenter,
    NVAlertViewShowAnimationSlideInToCenter,
    NVAlertViewShowAnimationSimplyAppear
};
```

#### 背景框效果
```Objective-C
typedef NS_ENUM(NSInteger, NVAlertViewBackground)
{
    NVAlertViewBackgroundShadow,
    NVAlertViewBackgroundBlur,
    NVAlertViewBackgroundTransparent
};
```

### 安装
NVAlertView is available through :

### [CocoaPods](https://cocoapods.org)

To install add the following line to your Podfile:

    pod 'NVAlertView'



