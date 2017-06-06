//
//  NVAlertView.m
//  NVAlertView
//
//  Created by Diogo Autilio on 9/26/14.
//  Copyright (c) 2014-2016 AnyKey Entertainment. All rights reserved.
//

#import "NVAlertView.h"
#import "NVAlertViewResponder.h"
#import "NVAlertViewStyleKit.h"
#import "UIImage+ImageEffects.h"
#import "NVTimerDisplay.h"
#import "NVMacros.h"

#if defined(__has_feature) && __has_feature(modules)
@import AVFoundation;
@import AudioToolbox;
#else
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#endif

#define KEYBOARD_HEIGHT 80
#define PREDICTION_BAR_HEIGHT 40
#define ADD_BUTTON_PADDING 10.0f
#define DEFAULT_WINDOW_WIDTH 240

@interface NVAlertView ()  <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *inputs;
@property (strong, nonatomic) NSMutableArray *customViews;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) UIImageView *circleIconImageView;
@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) UIView *circleViewBackground;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIButton *closeBottomButton;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) NSString *titleFontFamily;
@property (strong, nonatomic) NSString *bodyTextFontFamily;
@property (strong, nonatomic) NSString *buttonsFontFamily;
@property (strong, nonatomic) UIWindow *previousWindow;
@property (strong, nonatomic) UIWindow *NVAlertWindow;
@property (copy, nonatomic) NVDismissBlock dismissBlock;
@property (copy, nonatomic) NVDismissAnimationCompletionBlock dismissAnimationCompletionBlock;
@property (copy, nonatomic) NVShowAnimationCompletionBlock showAnimationCompletionBlock;
@property (weak, nonatomic) UIViewController *rootViewController;
@property (weak, nonatomic) id<UIGestureRecognizerDelegate> restoreInteractivePopGestureDelegate;
@property (assign, nonatomic) SystemSoundID soundID;
@property (assign, nonatomic) BOOL canAddObservers;
@property (assign, nonatomic) BOOL keyboardIsVisible;
@property (assign, nonatomic) BOOL usingNewWindow;
@property (assign, nonatomic) BOOL restoreInteractivePopGestureEnabled;
@property (nonatomic) CGFloat backgroundOpacity;
@property (nonatomic) CGFloat titleFontSize;
@property (nonatomic) CGFloat bodyFontSize;
@property (nonatomic) CGFloat buttonsFontSize;
@property (nonatomic) CGFloat windowHeight;
@property (nonatomic) CGFloat windowWidth;
@property (nonatomic) CGFloat subTitleHeight;
@property (nonatomic) CGFloat subTitleY;

@end

@implementation NVAlertView

CGFloat kCircleHeight;
CGFloat kCircleTopPosition;
CGFloat kCircleBackgroundTopPosition;
CGFloat kCircleHeightBackground;
CGFloat kActivityIndicatorHeight;
CGFloat kTitleTop;
CGFloat kTitleHeight;


//gyk
CGFloat kCloseButtonHeight;      //关闭按钮的高度
CGFloat kCloseButtonTopPosition; //距离contentView的距离

// Timer
NSTimer *durationTimer;
NVTimerDisplay *buttonTimer;

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"NSCoding not supported"
                                 userInfo:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupViewWindowWidth:DEFAULT_WINDOW_WIDTH];
    }
    return self;
}


//宽度可以自己传入， newWindow默认是 240
- (instancetype)initWithWindowWidth:(CGFloat)windowWidth
{
    self = [super init];
    if (self)
    {
   
        [self setupViewWindowWidth:windowWidth];
    }
    return self;
}

- (instancetype)initWithNewWindow
{
    //默认宽度240 没有随着变化
    self = [self initWithWindowWidth:DEFAULT_WINDOW_WIDTH];
    
    //在self.view上添加了许多的东西
    
    if(self)
    {
    
        //回到创建window 此时子视图已经添加 有一些默认高度
        //把self.view的视图加到一个新创建的window上
        [self setupNewWindow];
        //contentFrame = {0,0,0,0}
        
    }
    return self;
}

- (instancetype)initWithNewWindowWidth:(CGFloat)windowWidth
{
    self = [self initWithWindowWidth:windowWidth];
    if(self)
    {
        [self setupNewWindow];
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
    [self restoreInteractivePopGesture];
}

- (void)addObservers
{
    if(_canAddObservers)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _canAddObservers = NO;
    }
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Setup view
/**
 创建添加子视图 
 
 层次结构:self.view{_contentView[_viewText], _circleViewBack[_circleView, _circleImage] , _labelTitle}

 @param windowWidth window宽度
 */
- (void)setupViewWindowWidth:(CGFloat)windowWidth
{
    // Default values
    kCircleBackgroundTopPosition = -15.0f;
    kCircleHeight = 56.0f;
    
    //圆形背景宽度
    kCircleHeightBackground = 62.0f;
    kActivityIndicatorHeight = 40.0f;
    
    //title距离顶部距离
    kTitleTop = 30.0f;
    
    
    //标题高度
    kTitleHeight = 40.0f;
    self.subTitleY = 70.0f;
    self.subTitleHeight = 90.0f;
    self.circleIconHeight = 20.0f;
    self.windowWidth = windowWidth;
    self.windowHeight = 178.0f;
    
    //关闭按钮
    kCloseButtonHeight = 34.0f;
    kCloseButtonTopPosition = 32.0f; //关闭按钮距离顶部视图距离
    
    
    self.shouldDismissOnTapOutside = NO;
    self.usingNewWindow = NO;
    self.canAddObservers = YES;
    self.keyboardIsVisible = NO;
    self.hideAnimationType =  NVAlertViewHideAnimationFadeOut;
    self.showAnimationType = NVAlertViewShowAnimationSlideInFromTop;
    self.backgroundType = NVAlertViewBackgroundShadow;
    self.tintTopCircle = YES;
    
    // Font
    _titleFontFamily = @"HelveticaNeue";
    _bodyTextFontFamily = @"HelveticaNeue";
    _buttonsFontFamily = @"HelveticaNeue-Bold";
    _titleFontSize = 20.0f;
    _bodyFontSize = 14.0f;
    _buttonsFontSize = 14.0f;
    
    // Init
    _labelTitle = [[UILabel alloc] init];
    
    _viewText = [[UITextView alloc] init];
    
    _contentView = [[UIView alloc] init];
    
    //带色圆形
    _circleView = [[UIView alloc] init];
    
    //白色圆形背景
    _circleViewBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kCircleHeightBackground, kCircleHeightBackground)];
    
    //图片imageView
    _circleIconImageView = [[UIImageView alloc] init];
    
    //背景视图 是一张图片和主屏一样大小
    _backgroundView = [[UIImageView alloc]initWithFrame:[self mainScreenFrame]];
    
    //按钮数组
    _buttons = [[NSMutableArray alloc] init];
    
    //输入框数组
    _inputs = [[NSMutableArray alloc] init];
    
    //自定义视图数组
    _customViews = [[NSMutableArray alloc] init];
    
    // Add Subviews 自己是一个控制器
    [self.view addSubview:_contentView];
    //1.第一次添加  [ self.view[_contentView, _circleViewBack] ]
    
    
    //doing:根据风格判断是否加圆
    [self.view addSubview:_circleViewBackground];
    
    // Circle View kCircleHeight = 64
    //白色圆弧边框宽度
    CGFloat x = (kCircleHeightBackground - kCircleHeight) / 2;
    
    _circleView.frame = CGRectMake(x, x, kCircleHeight, kCircleHeight);
    _circleView.layer.cornerRadius = _circleView.frame.size.height / 2;
    
    // Circle Background View
    _circleViewBackground.backgroundColor = [UIColor whiteColor];
    _circleViewBackground.layer.cornerRadius = _circleViewBackground.frame.size.height / 2;
    
    //图片相对颜色circle 的x
    x = (kCircleHeight - _circleIconHeight) / 2;
    
    // Circle Image View
    //外部可以根据属性设置 图片的宽高
    _circleIconImageView.frame = CGRectMake(x, x, _circleIconHeight, _circleIconHeight);
    _circleIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //层次关系
    // [ self.view[_contentView, _circleViewBack[_circleView, _circleImage]] ]
    
    
    [_circleViewBackground addSubview:_circleView];
    [_circleView addSubview:_circleIconImageView];
    
    // Background View
    _backgroundView.userInteractionEnabled = YES;
    
    
    
    // Title
    _labelTitle.numberOfLines = 1;
    
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.font = [UIFont fontWithName:_titleFontFamily size:_titleFontSize];
    
    //顶部kTitleTop = 30  kTitleHeight = 40
    //_windowWidth = 是 弹框的白色 宽度  两边  12
    _labelTitle.frame = CGRectMake(12.0f, kTitleTop, _windowWidth - 24.0f, kTitleHeight);
    
    //gyk
    //_labelTitle.backgroundColor = [UIColor redColor];
    
    // View text
    //不可编辑的文字
    _viewText.editable = NO;
    
    //gyk
    //_viewTextColor是 subTitle， 详情文字
    _viewText.allowsEditingTextAttributes = YES;
    _viewText.textAlignment = NSTextAlignmentCenter;
    _viewText.font = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
    
    //初始化时候是90之后会 更新
    _viewText.frame = CGRectMake(12.0f, _subTitleY, _windowWidth - 24.0f, _subTitleHeight);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        _viewText.textContainerInset = UIEdgeInsetsZero;
        _viewText.textContainer.lineFragmentPadding = 0;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // Content View
    
    _contentView.backgroundColor = [UIColor whiteColor];
    //_contentView 是弹框底部白色视图
    
    //圆角设置为5
    _contentView.layer.cornerRadius = 5.0f;
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.borderWidth = 0.5f;
    [_contentView addSubview:_viewText];
    
    //self.view{_contentView[_viewText], _circleViewBack[_circleView, _circleImage], _labelTitle}

    
   
    
    //self.labelTitle的frame 转换为 在  self.view的frame  添加到 self.view上
    CGRect position = [self.contentView convertRect:self.labelTitle.frame toView:self.view];
    _labelTitle.frame = position;
    [self.view addSubview:_labelTitle];
    
    // Colors
    
    //circle背景白色  subTitle白色 content白色
    self.backgroundViewColor = [UIColor whiteColor];
    
    //文字颜色
    _labelTitle.textColor = UIColorFromHEX(0x4D4D4D); //Dark Grey
    _viewText.textColor = UIColorFromHEX(0x4D4D4D); //Dark Grey
    _contentView.layer.borderColor = UIColorFromHEX(0xCCCCCC).CGColor; //Light Grey
    
    
    //content 就是弹框
    //_contentView.backgroundColor = [UIColor greenColor];
}



- (void)setupNewWindow
{
    // Create a new one to show the alert
    
    //创建Window 大小和主屏幕一样大小
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[self mainScreenFrame]];
    
    alertWindow.windowLevel = UIWindowLevelAlert;
    
    //颜色透明
    alertWindow.backgroundColor = [UIColor clearColor];
    
    //weindow的更控制器的 自己 ViewController 会把 self.view加到window上
    
    alertWindow.rootViewController = self;
    
    //属性保存
    self.NVAlertWindow = alertWindow;
    
    //使用了 新创建的window
    self.usingNewWindow = YES;
}

#pragma mark - Modal Validation

- (BOOL)isModal
{
    return (_rootViewController != nil && _rootViewController.presentingViewController);
}

#pragma mark - View Cycle

- (void)viewWillLayoutSubviews
{
    
    
    [super viewWillLayoutSubviews];
    
    CGSize sz = [self mainScreenFrame].size;
    // Check for larger top circle icon flag
    if (_useLargerIcon) {
        
        
        // Adjust icon
        _circleIconHeight = 70.0f;
        
        // Adjust coordinate variables for larger sized top circle
        kCircleBackgroundTopPosition = -61.0f;
        kCircleHeight = 106.0f;
        kCircleHeightBackground = 122.0f;
        
        // Reposition inner circle appropriately
        //_circleView
        CGFloat x = (kCircleHeightBackground - kCircleHeight) / 2;
        _circleView.frame = CGRectMake(x, x, kCircleHeight, kCircleHeight);
        if (_labelTitle.text == nil)
        {
            kTitleTop = kCircleHeightBackground / 2;
        }
    } else {
        
        //没有用更大的图片 -62/2
        kCircleBackgroundTopPosition = -(kCircleHeightBackground / 2);
    }
    
    // Check if the rootViewController is modal, if so we need to get the modal size not the main screen size
    if([self isModal] && !_usingNewWindow)
    {
        sz = _rootViewController.view.frame.size;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        // iOS versions before 7.0 did not switch the width and height on device roration
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            CGSize ssz = sz;
            sz = CGSizeMake(ssz.height, ssz.width);
        }
    }
    
    if(!_usingNewWindow)
    {
        //没有用newWindow，用的是self.view
        // Set new background frame
        CGRect newBackgroundFrame = self.backgroundView.frame;
        newBackgroundFrame.size = sz;
        self.backgroundView.frame = newBackgroundFrame;
        
        // Set new main frame
        CGRect r;
        if (self.view.superview != nil)
        {
            // View is showing, position at center of screen
            r = CGRectMake((sz.width-_windowWidth)/2, (sz.height-_windowHeight)/2, _windowWidth, _windowHeight);
        }
        else
        {
            // View is not visible, position outside screen bounds
            r = CGRectMake((sz.width-_windowWidth)/2, -_windowHeight, _windowWidth, _windowHeight);
        }
        
        // Set frames
        self.view.frame = r;
        _contentView.frame = CGRectMake(0.0f, 0.0f, _windowWidth, _windowHeight);
        
        //圆形背景层
        //下降一半的圆半径
        _circleViewBackground.frame = CGRectMake(_windowWidth / 2 - kCircleHeightBackground / 2, kCircleBackgroundTopPosition, kCircleHeightBackground, kCircleHeightBackground);
        
        _circleViewBackground.layer.cornerRadius = _circleViewBackground.frame.size.height / 2;
        _circleView.layer.cornerRadius = _circleView.frame.size.height / 2;
        _circleIconImageView.frame = CGRectMake(kCircleHeight / 2 - _circleIconHeight / 2, kCircleHeight / 2 - _circleIconHeight / 2, _circleIconHeight, _circleIconHeight);
        _labelTitle.frame = CGRectMake(12.0f, kTitleTop, _windowWidth - 24.0f, kTitleHeight);
        
        //关闭按钮的frame
        CGFloat contentViewBottom = _contentView.frame.origin.y + _contentView.frame.size.height;
 
        CGFloat kCloseButtonWidth = kCloseButtonHeight;
        _closeBottomButton.frame = CGRectMake(_windowWidth / 2 - kCloseButtonWidth/2, kCloseButtonTopPosition + contentViewBottom, kCloseButtonWidth, kCloseButtonHeight);
        //圆形设置layer设置
        _closeBottomButton.layer.cornerRadius = _closeBottomButton.frame.size.height / 2;
    }
    else
    {
        
        //使用的是window
        CGFloat x = (sz.width - _windowWidth) / 2;
        CGFloat y = (sz.height - _windowHeight - (kCircleHeight / 8)) / 2;
        
        _contentView.frame = CGRectMake(x, y, _windowWidth, _windowHeight);
        y -= kCircleHeightBackground / 2;
        x = (sz.width - kCircleHeightBackground) / 2;
    
        _circleView.layer.cornerRadius = _circleView.frame.size.height / 2;        
        _circleViewBackground.frame = CGRectMake(x, y, kCircleHeightBackground, kCircleHeightBackground);
        _circleViewBackground.layer.cornerRadius = _circleViewBackground.frame.size.height / 2;        
        _circleIconImageView.frame = CGRectMake(kCircleHeight / 2 - _circleIconHeight / 2, kCircleHeight / 2 - _circleIconHeight / 2, _circleIconHeight, _circleIconHeight);
        
        _labelTitle.frame = CGRectMake(12.0f + self.contentView.frame.origin.x, kTitleTop + self.contentView.frame.origin.y, _windowWidth - 24.0f, kTitleHeight);
        
        //kCircleBackgroundTopPosition 顶部距离
        CGFloat kCloseButtonWidth = kCloseButtonHeight;
        CGFloat contentViewBottom = _contentView.frame.origin.y + _contentView.frame.size.height;
        
        _closeBottomButton.frame = CGRectMake(sz.width / 2 - kCloseButtonWidth/2, kCloseButtonTopPosition + contentViewBottom, kCloseButtonWidth, kCloseButtonHeight);
        _closeBottomButton.layer.cornerRadius = _closeBottomButton.frame.size.height / 2;
               
    }
    
    // Text fields
    CGFloat y = (_labelTitle.text == nil) ? kTitleTop : kTitleTop + _labelTitle.frame.size.height;
    _viewText.frame = CGRectMake(12.0f, y, _windowWidth - 24.0f, _subTitleHeight);
    
    if (!_labelTitle && !_viewText) {
        y = 0.0f;
    }

    y += _subTitleHeight + 14.0f;
    
    //先添加输入框
    for (NVTextView *textField in _inputs)
    {
        textField.frame = CGRectMake(12.0f, y, _windowWidth - 24.0f, textField.frame.size.height);
        textField.layer.cornerRadius = 3.0f;
        y += textField.frame.size.height + 10.0f;
    }
    
    // Custom views
    //自定义视图
    for (UIView *view in _customViews)
    {
        view.frame = CGRectMake(12.0f, y, view.frame.size.width, view.frame.size.height);
        y += view.frame.size.height + 10.0f;
    }
    
    // Buttons
    // 按钮视图
    CGFloat x = 12.0f;
    for (NVButton *btn in _buttons)
    {
        btn.frame = CGRectMake(x, y, btn.frame.size.width, btn.frame.size.height);
        
        // Add horizontal or vertical offset acording on _horizontalButtons parameter
        if (_horizontalButtons) {
            x += btn.frame.size.width + 10.0f;
        } else {
            y += btn.frame.size.height + 10.0f;
        }
    }
    
    // Adapt window height according to icon size
    self.windowHeight = _useLargerIcon ? y : self.windowHeight;
    _contentView.frame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, _windowWidth, _windowHeight);
    
    // Adjust corner radius, if a value has been passed
    _contentView.layer.cornerRadius = self.cornerRadius ? self.cornerRadius : 5.0f;
    

}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

#pragma mark - Handle gesture

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (_shouldDismissOnTapOutside)
    {
        BOOL hide = _shouldDismissOnTapOutside;
        
        for(NVTextView *txt in _inputs)
        {
            // Check if there is any keyboard on screen and dismiss
            if (txt.editing)
            {
                [txt resignFirstResponder];
                hide = NO;
            }
        }
        if(hide)[self hideView];
    }
}

- (void)setShouldDismissOnTapOutside:(BOOL)shouldDismissOnTapOutside
{
    _shouldDismissOnTapOutside = shouldDismissOnTapOutside;
    
    if(_shouldDismissOnTapOutside)
    {
        self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_usingNewWindow ? _NVAlertWindow : _backgroundView addGestureRecognizer:_gestureRecognizer];
    }
}

- (void)disableInteractivePopGesture
{
    UINavigationController *navigationController;
    
    if([_rootViewController isKindOfClass:[UINavigationController class]])
    {
        navigationController = ((UINavigationController*)_rootViewController);
    }
    else
    {
        navigationController = _rootViewController.navigationController;
    }
    
    // Disable iOS 7 back gesture
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        _restoreInteractivePopGestureEnabled = navigationController.interactivePopGestureRecognizer.enabled;
        _restoreInteractivePopGestureDelegate = navigationController.interactivePopGestureRecognizer.delegate;
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)restoreInteractivePopGesture
{
    UINavigationController *navigationController;
    
    if([_rootViewController isKindOfClass:[UINavigationController class]])
    {
        navigationController = ((UINavigationController*)_rootViewController);
    }
    else
    {
        navigationController = _rootViewController.navigationController;
    }
    
    // Restore iOS 7 back gesture
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled = _restoreInteractivePopGestureEnabled;
        navigationController.interactivePopGestureRecognizer.delegate = _restoreInteractivePopGestureDelegate;
    }
}

#pragma mark - Custom Fonts

- (void)setTitleFontFamily:(NSString *)titleFontFamily withSize:(CGFloat)size
{
    self.titleFontFamily = titleFontFamily;
    self.titleFontSize = size;
    self.labelTitle.font = [UIFont fontWithName:_titleFontFamily size:_titleFontSize];
}

- (void)setBodyTextFontFamily:(NSString *)bodyTextFontFamily withSize:(CGFloat)size
{
    self.bodyTextFontFamily = bodyTextFontFamily;
    self.bodyFontSize = size;
    self.viewText.font = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
}

- (void)setButtonsTextFontFamily:(NSString *)buttonsFontFamily withSize:(CGFloat)size
{
    self.buttonsFontFamily = buttonsFontFamily;
    self.buttonsFontSize = size;
}

#pragma mark - Background Color
- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor
{
    _backgroundViewColor = backgroundViewColor;
    _circleViewBackground.backgroundColor = _backgroundViewColor;
    _contentView.backgroundColor = _backgroundViewColor;
    
    //yellocollor
    _viewText.backgroundColor = _backgroundViewColor;
    //_viewText.backgroundColor = [UIColor yellowColor];
}

#pragma mark - Sound

- (void)setSoundURL:(NSURL *)soundURL
{
    _soundURL = soundURL;
    
    //DisposeSound
    AudioServicesDisposeSystemSoundID(_soundID);
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)_soundURL, &_soundID);
    
    //PlaySound
    AudioServicesPlaySystemSound(_soundID);
}

#pragma mark - Subtitle Height

- (void)setSubTitleHeight:(CGFloat)value
{
    _subTitleHeight = value;
}

#pragma mark - ActivityIndicator

- (void)addActivityIndicatorView
{
    // Add UIActivityIndicatorView
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.frame = CGRectMake(kCircleHeight / 2 - kActivityIndicatorHeight / 2, kCircleHeight / 2 - kActivityIndicatorHeight / 2, kActivityIndicatorHeight, kActivityIndicatorHeight);
    [_circleView addSubview:_activityIndicatorView];
}

#pragma mark - UICustomView

- (UIView *)addCustomView:(UIView *)customView
{
    // Update view height
    self.windowHeight += customView.bounds.size.height + 10.0f;
    
    [_contentView addSubview:customView];
    [_customViews addObject:customView];
    
    return customView;
}

#pragma mark - SwitchView

- (NVSwitchView *)addSwitchViewWithLabel:(NSString *)label
{
    // Add switch view
    NVSwitchView *switchView = [[NVSwitchView alloc] initWithFrame:CGRectMake(0, 0, self.windowWidth, 31.0f)];
    
    // Update view height
    self.windowHeight += switchView.bounds.size.height + 10.0f;
    
    if (label != nil)
    {
        switchView.labelText = label;
    }
    
    [_contentView addSubview:switchView];
    [_inputs addObject:switchView];
    
    return switchView;
}

#pragma mark - TextField

- (NVTextView *)addTextField:(NSString *)title
{
    [self addObservers];
    
    // Add text field
    NVTextView *txt = [[NVTextView alloc] init];
    txt.font = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
    txt.delegate = self;
    
    // Update view height
    self.windowHeight += txt.bounds.size.height + 10.0f;
    
    if (title != nil)
    {
        txt.placeholder = title;
    }
    
    [_contentView addSubview:txt];
    [_inputs addObject:txt];
    
    // If there are other fields in the inputs array, get the previous field and set the
    // return key type on that to next.
    if (_inputs.count > 1)
    {
        NSUInteger indexOfCurrentField = [_inputs indexOfObject:txt];
        NVTextView *priorField = _inputs[indexOfCurrentField - 1];
        priorField.returnKeyType = UIReturnKeyNext;
    }
    return txt;
}

- (void)addCustomTextField:(UITextField *)textField
{
    // Update view height
    self.windowHeight += textField.bounds.size.height + 10.0f;
    
    [_contentView addSubview:textField];
    [_inputs addObject:textField];
    
    // If there are other fields in the inputs array, get the previous field and set the
    // return key type on that to next.
    if (_inputs.count > 1)
    {
        NSUInteger indexOfCurrentField = [_inputs indexOfObject:textField];
        UITextField *priorField = _inputs[indexOfCurrentField - 1];
        priorField.returnKeyType = UIReturnKeyNext;
    }
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // If this is the last object in the inputs array, resign first responder
    // as the form is at the end.
    if (textField == _inputs.lastObject)
    {
        [textField resignFirstResponder];
    }
    else // Otherwise find the next field and make it first responder.
    {
        NSUInteger indexOfCurrentField = [_inputs indexOfObject:textField];
        UITextField *nextField = _inputs[indexOfCurrentField + 1];
        [nextField becomeFirstResponder];
    }
    return NO;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(_keyboardIsVisible) return;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect f = self.view.frame;
        f.origin.y -= KEYBOARD_HEIGHT + PREDICTION_BAR_HEIGHT;
        self.view.frame = f;
    }];
    _keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if(!_keyboardIsVisible) return;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect f = self.view.frame;
        f.origin.y += KEYBOARD_HEIGHT + PREDICTION_BAR_HEIGHT;
        self.view.frame = f;
    }];
    _keyboardIsVisible = NO;
}

#pragma mark - Buttons

- (NVButton *)addButton:(NSString *)title
{
    // Add button
    NVButton *btn = [[NVButton alloc] initWithWindowWidth:self.windowWidth];
    btn.layer.masksToBounds = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:_buttonsFontFamily size:_buttonsFontSize];
    
    [_contentView addSubview:btn];
    [_buttons addObject:btn];
    
    if (_horizontalButtons) {
        // Update buttons width according to the number of buttons
        for (NVButton *bttn in _buttons) {
            [bttn adjustWidthWithWindowWidth:self.windowWidth numberOfButtons:[_buttons count]];
        }
        
        // Update view height
        if (!([_buttons count] > 1)) {
            self.windowHeight += (btn.frame.size.height + ADD_BUTTON_PADDING);
        }
    } else {
        // Update view height
        self.windowHeight += (btn.frame.size.height + ADD_BUTTON_PADDING);
    }
    
    return btn;
}

- (NVButton *)addDoneButtonWithTitle:(NSString *)title
{
    NVButton *btn = [self addButton:title];
    
    if (_completeButtonFormatBlock != nil)
    {
        btn.completeButtonFormatBlock = _completeButtonFormatBlock;
    }
    
    [btn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (NVButton *)addButton:(NSString *)title actionBlock:(NVActionBlock)action
{
    NVButton *btn = [self addButton:title];
    
    if (_buttonFormatBlock != nil)
    {
        btn.buttonFormatBlock = _buttonFormatBlock;
    }
    
    btn.actionType = NVBlock;
    btn.actionBlock = action;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (NVButton *)addButton:(NSString *)title validationBlock:(NVValidationBlock)validationBlock actionBlock:(NVActionBlock)action
{
    NVButton *btn = [self addButton:title actionBlock:action];
    btn.validationBlock = validationBlock;
    
    return btn;
}

- (NVButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector
{
    NVButton *btn = [self addButton:title];
    btn.actionType = NVSelector;
    btn.target = target;
    btn.selector = selector;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)buttonTapped:(NVButton *)btn
{
    // Cancel Countdown timer
    [buttonTimer cancelTimer];
    
    // If the button has a validation block, and the validation block returns NO, validation
    // failed, so we should bail.
    if (btn.validationBlock && !btn.validationBlock()) {
        return;
    }
    
    if (btn.actionType == NVBlock)
    {
        if (btn.actionBlock)
            btn.actionBlock();
    }
    else if (btn.actionType == NVSelector)
    {
        UIControl *ctrl = [[UIControl alloc] init];
        [ctrl sendAction:btn.selector to:btn.target forEvent:nil];
    }
    else
    {
        NSLog(@"Unknown action type for button");
    }
    
    if([self isVisible])
    {
        [self hideView];
    }
}

#pragma mark - Button Timer

- (void)addTimerToButtonIndex:(NSInteger)buttonIndex reverse:(BOOL)reverse
{
    buttonIndex = MAX(buttonIndex, 0);
    buttonIndex = MIN(buttonIndex, [_buttons count]);
    
    buttonTimer = [[NVTimerDisplay alloc] initWithOrigin:CGPointMake(5, 5) radius:13 lineWidth:4];
    buttonTimer.buttonIndex = buttonIndex;
    buttonTimer.reverse = reverse;
}

#pragma mark - Show Alert

- (NVAlertViewResponder *)showTitle:(UIViewController *)vc image:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle duration:(NSTimeInterval)duration completeText:(NSString *)completeText style:(NVAlertViewStyle)style
{
    if(_usingNewWindow)
    {
        // Save previous window
        self.previousWindow = [UIApplication sharedApplication].keyWindow;
        self.backgroundView.frame = _NVAlertWindow.bounds;
        
        // Add window subview
        //gyk
        //_backgroundView.backgroundColor = [UIColor redColor];
        [_NVAlertWindow addSubview:_backgroundView];
    }
    else
    {
        _rootViewController = vc;
        
        [self disableInteractivePopGesture];
        
        self.backgroundView.frame = vc.view.bounds;
        
        // Add view controller subviews
        [_rootViewController addChildViewController:self];
        [_rootViewController.view addSubview:_backgroundView];
        [_rootViewController.view addSubview:self.view];
    }
    
    self.view.alpha = 0.0f;
    [self setBackground];
    
    // Alert color/icon
    UIColor *viewColor;
    UIImage *iconImage;
    
    // Icon style
    
    //根据不同的icon风格加入 - 需要自己花一个 关闭按钮
    switch (style)
    {
        case NVAlertViewStyleSuccess:
            viewColor = UIColorFromHEX(0x22B573);
            iconImage = NVAlertViewStyleKit.imageOfCheckmark;
            break;
            
        case NVAlertViewStyleError:
            viewColor = UIColorFromHEX(0xC1272D);
            iconImage = NVAlertViewStyleKit.imageOfCross;
            break;
            
        case NVAlertViewStyleNotice:
            viewColor = UIColorFromHEX(0x727375);
            iconImage = NVAlertViewStyleKit.imageOfNotice;
            break;
            
        case NVAlertViewStyleWarning:
            viewColor = UIColorFromHEX(0xFFD110);
            iconImage = NVAlertViewStyleKit.imageOfWarning;
            break;
            
        case NVAlertViewStyleInfo:
            viewColor = UIColorFromHEX(0x2866BF);
            iconImage = NVAlertViewStyleKit.imageOfInfo;
            break;
            
        case NVAlertViewStyleEdit:
            viewColor = UIColorFromHEX(0xA429FF);
            iconImage = NVAlertViewStyleKit.imageOfEdit;
            break;
            
        case NVAlertViewStyleWaiting:
            viewColor = UIColorFromHEX(0x6c125d);
            break;
            
        case NVAlertViewStyleQuestion:
            viewColor = UIColorFromHEX(0x727375);
            iconImage = NVAlertViewStyleKit.imageOfQuestion;
            break;
            
        case NVAlertViewStyleCustom:
            viewColor = color;
            iconImage = image;
            self.circleIconHeight *= 2.0f;
            break;
        case NVAlertViewStyleCloseButtonUnderBottom:
            [self addCloseButtonBottom];
            break;
    }
    
    // Custom Alert color
    if(_customViewColor)
    {
        viewColor = _customViewColor;
    }
    
    
    if (style == NVAlertViewStyleCloseButtonUnderBottom) {

        //移除顶部类型视图
        if (_circleViewBackground) {
            [_circleViewBackground removeFromSuperview];
        }
        //之前标题距离顶部 是 30的 距离
        kTitleTop = 12.0f;
        
        //修改总高度
        self.windowHeight -= 18;
    }
    
    
    
    // Title
    if([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        self.labelTitle.text = title;
    }
    else
    {
        // Title is nil, we can move the body message to center and remove it from superView
        self.windowHeight -= _labelTitle.frame.size.height;
        [_labelTitle removeFromSuperview];
        _labelTitle = nil;
        
        _subTitleY = kCircleHeight - 20;
    }
    
    // Subtitle
    if([subTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        // No custom text
        if (_attributedFormatBlock == nil)
        {
            _viewText.text = subTitle;
        }
        else
        {
            self.viewText.font = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
            _viewText.attributedText = self.attributedFormatBlock(subTitle);
        }
        
        // Adjust text view size, if necessary
        CGSize sz = CGSizeMake(_windowWidth - 24.0f, CGFLOAT_MAX);
        
        CGSize size = [_viewText sizeThatFits:sz];
        
        CGFloat ht = ceilf(size.height);
        if (ht < _subTitleHeight)
        {
            self.windowHeight -= (_subTitleHeight - ht);
            self.subTitleHeight = ht;
        }
        else
        {
            self.windowHeight += (ht - _subTitleHeight);
            self.subTitleHeight = ht;
        }
        _viewText.frame = CGRectMake(12.0f, _subTitleY, _windowWidth - 24.0f, _subTitleHeight);
    }
    else
    {
        // Subtitle is nil, we can move the title to center and remove it from superView
        self.subTitleHeight = 0.0f;
        self.windowHeight -= _viewText.frame.size.height;
        [_viewText removeFromSuperview];
        _viewText = nil;
        
        // Move up
        _labelTitle.frame = CGRectMake(12.0f, 37.0f, _windowWidth - 24.0f, kTitleHeight);
    }
    
    if (!_labelTitle && !_viewText) {
        self.windowHeight -= kTitleTop;
    }
    
    // Add button, if necessary
    if(completeText != nil)
    {
        [self addDoneButtonWithTitle:completeText];
    }
    
    // Alert view color and images
    self.circleView.backgroundColor = self.tintTopCircle ? viewColor : _backgroundViewColor;
    
    if (style == NVAlertViewStyleWaiting)
    {
        [self.activityIndicatorView startAnimating];
    }
    else
    {
        if (self.iconTintColor) {
            self.circleIconImageView.tintColor = self.iconTintColor;
            iconImage  = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        //设置类别图标了
        self.circleIconImageView.image = iconImage;
    }
    
    for (NVTextView *textField in _inputs)
    {
        textField.layer.borderColor = viewColor.CGColor;
    }
    
    for (NVButton *btn in _buttons)
    {
        if (style == NVAlertViewStyleWarning)
        {
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        if (!btn.defaultBackgroundColor) {
            btn.defaultBackgroundColor = viewColor;
        }
        
        if (btn.completeButtonFormatBlock != nil)
        {
            [btn parseConfig:btn.completeButtonFormatBlock()];
        }
        else if (btn.buttonFormatBlock != nil)
        {
            [btn parseConfig:btn.buttonFormatBlock()];
        }
    }
    
    // Adding duration
    if (duration > 0)
    {
        [durationTimer invalidate];
        
        if (buttonTimer && _buttons.count > 0)
        {
            NVButton *btn = _buttons[buttonTimer.buttonIndex];
            btn.timer = buttonTimer;
            [buttonTimer startTimerWithTimeLimit:duration completed:^{
                [self buttonTapped:btn];
            }];
        }
        else
        {
            durationTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                             target:self
                                                           selector:@selector(hideView)
                                                           userInfo:nil
                                                            repeats:NO];
        }
    }
    
    if(_usingNewWindow)
    {
        [_NVAlertWindow makeKeyAndVisible];
    }
    
    // Show the alert view
    [self showView];
    
    // Chainable objects
    return [[NVAlertViewResponder alloc] init:self];
}


//在底部添加原型按钮
- (void)addCloseButtonBottom{
    UIButton *closeBottomButton = [[UIButton alloc] init];
    closeBottomButton.frame = CGRectMake(0, 0, 100, 100);
    self.closeBottomButton = closeBottomButton;
    [self.closeBottomButton setBackgroundImage:NVAlertViewStyleKit.imageOfClose forState:UIControlStateNormal];
    [self.closeBottomButton addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    closeBottomButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:closeBottomButton];
}

#pragma mark - Show using UIViewController


//没有传递closeButton的title， 就不在 框内加入了
- (void)showCloseButton:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle duration:(NSTimeInterval)duration{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:nil style:NVAlertViewStyleCloseButtonUnderBottom];
}

- (void)showSuccess:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleSuccess];
}

- (void)showError:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleError];
}

- (void)showNotice:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleNotice];
}

- (void)showWarning:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleWarning];
}

- (void)showInfo:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleInfo];
}

- (void)showEdit:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleEdit];
}

- (void)showTitle:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle style:(NVAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:style];
}

- (void)showCustom:(UIViewController *)vc image:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:image color:color title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleCustom];
}

- (void)showWaiting:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self addActivityIndicatorView];
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleWaiting];
}

- (void)showQuestion:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleQuestion];
}


#pragma mark - Show using new window

- (void)showSuccess:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleSuccess];
}

- (void)showError:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleError];
}

- (void)showNotice:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleNotice];
}

- (void)showWarning:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleWarning];
}

- (void)showInfo:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleInfo];
}

- (void)showEdit:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleEdit];
}

- (void)showTitle:(NSString *)title subTitle:(NSString *)subTitle style:(NVAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:style];
}

- (void)showCustom:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:image color:color title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleCustom];
}

- (void)showWaiting:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self addActivityIndicatorView];
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleWaiting];
}

- (void)showQuestion:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:nil image:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:NVAlertViewStyleQuestion];
}

#pragma mark - Visibility

- (void)removeTopCircle
{
    [_circleViewBackground removeFromSuperview];
    [_circleView removeFromSuperview];
}

- (BOOL)isVisible
{
    return (self.view.alpha);
}

- (void)alertIsDismissed:(NVDismissBlock)dismissBlock
{
    self.dismissBlock = dismissBlock;
}

- (void)alertDismissAnimationIsCompleted:(NVDismissAnimationCompletionBlock)dismissAnimationCompletionBlock{
    self.dismissAnimationCompletionBlock = dismissAnimationCompletionBlock;
}

- (void)alertShowAnimationIsCompleted:(NVShowAnimationCompletionBlock)showAnimationCompletionBlock{
    self.showAnimationCompletionBlock = showAnimationCompletionBlock;
}

- (NVForceHideBlock)forceHideBlock:(NVForceHideBlock)forceHideBlock
{
    _forceHideBlock = forceHideBlock;
    
    if (_forceHideBlock)
    {
        [self hideView];
    }
    return _forceHideBlock;
}

- (CGRect)mainScreenFrame
{
    return [self isAppExtension] ? _extensionBounds : [UIApplication sharedApplication].keyWindow.bounds;
}

- (BOOL)isAppExtension
{
    return [[NSBundle mainBundle].executablePath rangeOfString:@".appex/"].location != NSNotFound;
}

#pragma mark - Background Effects

- (void)makeShadowBackground
{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.7f;
    _backgroundOpacity = 0.7f;
}

- (void)makeBlurBackground
{
    UIView *appView = (_usingNewWindow) ? [UIApplication sharedApplication].keyWindow.subviews.lastObject : _rootViewController.view;
    UIImage *image = [UIImage convertViewToImage:appView];
    UIImage *blurSnapshotImage = [image applyBlurWithRadius:5.0f
                                                  tintColor:[UIColor colorWithWhite:0.2f
                                                                              alpha:0.7f]
                                      saturationDeltaFactor:1.8f
                                                  maskImage:nil];
    
    _backgroundView.image = blurSnapshotImage;
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)makeTransparentBackground
{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)setBackground
{
    switch (_backgroundType)
    {
        case NVAlertViewBackgroundShadow:
            [self makeShadowBackground];
            break;
            
        case NVAlertViewBackgroundBlur:
            [self makeBlurBackground];
            break;
            
        case NVAlertViewBackgroundTransparent:
            [self makeTransparentBackground];
            break;
    }
}

#pragma mark - Show Alert

- (void)showView
{
    switch (_showAnimationType)
    {
        case NVAlertViewShowAnimationFadeIn:
            [self fadeIn];
            break;
            
        case NVAlertViewShowAnimationSlideInFromBottom:
            [self slideInFromBottom];
            break;
            
        case NVAlertViewShowAnimationSlideInFromTop:
            [self slideInFromTop];
            break;
            
        case NVAlertViewShowAnimationSlideInFromLeft:
            [self slideInFromLeft];
            break;
            
        case NVAlertViewShowAnimationSlideInFromRight:
            [self slideInFromRight];
            break;
            
        case NVAlertViewShowAnimationSlideInFromCenter:
            [self slideInFromCenter];
            break;
            
        case NVAlertViewShowAnimationSlideInToCenter:
            [self slideInToCenter];
            break;
            
        case NVAlertViewShowAnimationSimplyAppear:
            [self simplyAppear];
            break;
    }
}

#pragma mark - Hide Alert

- (void)hideView
{
    switch (_hideAnimationType)
    {
        case NVAlertViewHideAnimationFadeOut:
            [self fadeOut];
            break;
            
        case NVAlertViewHideAnimationSlideOutToBottom:
            [self slideOutToBottom];
            break;
            
        case NVAlertViewHideAnimationSlideOutToTop:
            [self slideOutToTop];
            break;
            
        case NVAlertViewHideAnimationSlideOutToLeft:
            [self slideOutToLeft];
            break;
            
        case NVAlertViewHideAnimationSlideOutToRight:
            [self slideOutToRight];
            break;
            
        case NVAlertViewHideAnimationSlideOutToCenter:
            [self slideOutToCenter];
            break;
            
        case NVAlertViewHideAnimationSlideOutFromCenter:
            [self slideOutFromCenter];
            break;
        
        case NVAlertViewHideAnimationSimplyDisappear:
            [self simplyDisappear];
            break;
    }
    
    if (_activityIndicatorView)
    {
        [_activityIndicatorView stopAnimating];
    }
    
    if (durationTimer)
    {
        [durationTimer invalidate];
    }
    
    if (self.dismissBlock)
    {
        self.dismissBlock();
    }
    
    if (_usingNewWindow)
    {
        // Restore previous window
        [self.previousWindow makeKeyAndVisible];
        self.previousWindow = nil;
    }
    
    for (NVButton *btn in _buttons)
    {
        btn.actionBlock = nil;
        btn.target = nil;
        btn.selector = nil;
    }
}

#pragma mark - Hide Animations

- (void)fadeOut
{
    [self fadeOutWithDuration:0.3f];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.alpha = 0.0f;
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self.backgroundView removeFromSuperview];
        if (_usingNewWindow)
        {
            // Remove current window
            [self.NVAlertWindow setHidden:YES];
            self.NVAlertWindow = nil;
        }
        else
        {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
        if ( _dismissAnimationCompletionBlock ){
            self.dismissAnimationCompletionBlock();
        }
    }];
}

- (void)slideOutToBottom
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y += self.backgroundView.frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToTop
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y -= self.backgroundView.frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToLeft
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x -= self.backgroundView.frame.size.width;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToRight
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x += self.backgroundView.frame.size.width;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToCenter
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform =
        CGAffineTransformConcat(CGAffineTransformIdentity,
                                CGAffineTransformMakeScale(0.1f, 0.1f));
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutFromCenter
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform =
        CGAffineTransformConcat(CGAffineTransformIdentity,
                                CGAffineTransformMakeScale(3.0f, 3.0f));
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)simplyDisappear
{
    self.backgroundView.alpha = _backgroundOpacity;
    self.view.alpha = 1.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeOutWithDuration:0];
    });
}


#pragma mark - Show Animations

- (void)fadeIn
{
    self.backgroundView.alpha = 0.0f;
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.backgroundView.alpha = _backgroundOpacity;
                         self.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         if ( _showAnimationCompletionBlock ){
                             self.showAnimationCompletionBlock();
                         }
                     }];
}

- (void)slideInFromTop
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        //From Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = -self.backgroundView.frame.size.height;
        self.view.frame = frame;
        
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundView.alpha = _backgroundOpacity;
            
            //To Frame
            CGRect frame = self.backgroundView.frame;
            frame.origin.y = 0.0f;
            self.view.frame = frame;
            
            self.view.alpha = 1.0f;
        } completion:^(BOOL completed) {
            [UIView animateWithDuration:0.2f animations:^{
                self.view.center = _backgroundView.center;
            } completion:^(BOOL finished) {
                if ( _showAnimationCompletionBlock ){
                    self.showAnimationCompletionBlock();
                }
            }];
        }];
    }
    else {
        //From Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = -self.backgroundView.frame.size.height;
        self.view.frame = frame;
        
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:0 animations:^{
            self.backgroundView.alpha = _backgroundOpacity;
            
            //To Frame
            CGRect frame = self.backgroundView.frame;
            frame.origin.y = 0.0f;
            self.view.frame = frame;
            
            self.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if ( _showAnimationCompletionBlock ){
                self.showAnimationCompletionBlock();
            }
        }];
    }
}

- (void)slideInFromBottom
{
    //From Frame
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = self.backgroundView.frame.size.height;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        } completion:^(BOOL finished) {
            if ( _showAnimationCompletionBlock ){
                self.showAnimationCompletionBlock();
            }
        }];
    }];
}

- (void)slideInFromLeft
{
    //From Frame
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = -self.backgroundView.frame.size.width;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.x = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        } completion:^(BOOL finished) {
            if ( _showAnimationCompletionBlock ){
                self.showAnimationCompletionBlock();
            }
        }];
    }];
}

- (void)slideInFromRight
{
    //From Frame
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = self.backgroundView.frame.size.width;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.x = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        } completion:^(BOOL finished) {
            if ( _showAnimationCompletionBlock ){
                self.showAnimationCompletionBlock();
            }
        }];
    }];
}

- (void)slideInFromCenter
{
    //From Frame
    self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                  CGAffineTransformMakeScale(3.0f, 3.0f));
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                      CGAffineTransformMakeScale(1.0f, 1.0f));
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        } completion:^(BOOL finished) {
            if ( _showAnimationCompletionBlock ){
                self.showAnimationCompletionBlock();
            }
        }];
    }];
}

- (void)slideInToCenter
{
    //From Frame
    self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                  CGAffineTransformMakeScale(0.1f, 0.1f));
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                      CGAffineTransformMakeScale(1.0f, 1.0f));
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        } completion:^(BOOL finished) {
            if ( _showAnimationCompletionBlock ){
                self.showAnimationCompletionBlock();
            }
        }];
    }];
}

- (void)simplyAppear
{
    self.backgroundView.alpha = 0.0f;
    self.view.alpha = 0.0f;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = _backgroundOpacity;
        self.view.alpha = 1.0f;
        if ( _showAnimationCompletionBlock ){
            self.showAnimationCompletionBlock();
        }
    });
}


@end

@interface NVALertViewTextFieldBuilder()
#pragma mark - Parameters
@property(copy, nonatomic) NSString *parameterTitle;

#pragma mark - Available later after adding
@property(weak, nonatomic) NVTextView *textField;

#pragma mark - Setters
@property(copy, nonatomic) NVALertViewTextFieldBuilder *(^title) (NSString *title);
@end

@implementation NVALertViewTextFieldBuilder
- (NVALertViewTextFieldBuilder *(^) (NSString *title))title {
    if (!_title) {
        __weak typeof(self) weakSelf = self;
        _title = ^(NSString *title){
            weakSelf.parameterTitle = title;
            return weakSelf;
        };
    }
    return _title;
}
@end

@interface NVALertViewButtonBuilder()

#pragma mark - Parameters
@property(copy, nonatomic) NSString *parameterTitle;
@property(weak, nonatomic) id parameterTarget;
@property(assign, nonatomic) SEL parameterSelector;
@property(copy, nonatomic) void(^parameterActionBlock)(void);
@property(copy, nonatomic) BOOL(^parameterValidationBlock)(void);

#pragma mark - Available later after adding
@property(weak, nonatomic) NVButton *button;

#pragma mark - Setters
@property(copy, nonatomic) NVALertViewButtonBuilder *(^title) (NSString *title);
@property(copy, nonatomic) NVALertViewButtonBuilder *(^target) (id target);
@property(copy, nonatomic) NVALertViewButtonBuilder *(^selector) (SEL selector);
@property(copy, nonatomic) NVALertViewButtonBuilder *(^actionBlock) (void(^actionBlock)(void));
@property(copy, nonatomic) NVALertViewButtonBuilder *(^validationBlock) (BOOL(^validationBlock)(void));

@end

@implementation NVALertViewButtonBuilder
- (NVALertViewButtonBuilder *(^) (NSString *title))title {
    if (!_title) {
        __weak typeof(self) weakSelf = self;
        _title = ^(NSString *title){
            weakSelf.parameterTitle = title;
            return weakSelf;
        };
    }
    return _title;
}
- (NVALertViewButtonBuilder *(^) (id target))target {
    if (!_target) {
        __weak typeof(self) weakSelf = self;
        _target = ^(id target){
            weakSelf.parameterTarget = target;
            return weakSelf;
        };
    }
    return _target;
}
- (NVALertViewButtonBuilder *(^) (SEL selector))selector {
    if (!_selector) {
        __weak typeof(self) weakSelf = self;
        _selector = ^(SEL selector){
            weakSelf.parameterSelector = selector;
            return weakSelf;
        };
    }
    return _selector;
}
- (NVALertViewButtonBuilder *(^) (void(^actionBlock)(void)))actionBlock {
    if (!_actionBlock) {
        __weak typeof(self) weakSelf = self;
        _actionBlock = ^(void(^actionBlock)(void)){
            weakSelf.parameterActionBlock = actionBlock;
            return weakSelf;
        };
    }
    return _actionBlock;
}
- (NVALertViewButtonBuilder *(^) (BOOL(^validationBlock)(void)))validationBlock {
    if (!_validationBlock) {
        __weak typeof(self) weakSelf = self;
        _validationBlock = ^(BOOL(^validationBlock)(void)){
            weakSelf.parameterValidationBlock = validationBlock;
            return weakSelf;
        };
    }
    return _validationBlock;
}
@end


@interface NVAlertViewBuilder()

@property (strong, nonatomic) NVAlertView *alertView;

@end

@implementation NVAlertViewBuilder

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.alertView = [[NVAlertView alloc] init];
    }
    return self;
}
- (instancetype)initWithNewWindow {
    self = [super init];
    if (self) {
        self.alertView = [[NVAlertView alloc] initWithNewWindow];
    }
    return self;
}

- (instancetype)initWithNewWindowWidth:(CGFloat)width {
    self = [super init];
    if (self) {
        self.alertView = [[NVAlertView alloc] initWithNewWindowWidth:width];
    }
    return self;
}

#pragma mark - Properties
- (NVAlertViewBuilder *(^) (CGFloat cornerRadius))cornerRadius {
    if (!_cornerRadius) {
        __weak typeof(self) weakSelf = self;
        _cornerRadius = ^(CGFloat cornerRadius) {
            weakSelf.alertView.cornerRadius = cornerRadius;
            return weakSelf;
        };
    }
    return _cornerRadius;
}

- (NVAlertViewBuilder *(^) (BOOL tintTopCircle))tintTopCircle {
    if (!_tintTopCircle) {
        __weak typeof(self) weakSelf = self;
        _tintTopCircle = ^(BOOL tintTopCircle) {
            weakSelf.alertView.tintTopCircle = tintTopCircle;
            return weakSelf;
        };
    }
    return _tintTopCircle;
}
- (NVAlertViewBuilder *(^) (BOOL useLargerIcon))useLargerIcon {
    if (!_useLargerIcon) {
        __weak typeof(self) weakSelf = self;
        _useLargerIcon = ^(BOOL useLargerIcon) {
            weakSelf.alertView.useLargerIcon = useLargerIcon;
            return weakSelf;
        };
    }
    return _useLargerIcon;
}
- (NVAlertViewBuilder *(^) (UILabel *labelTitle))labelTitle {
    if (!_labelTitle) {
        __weak typeof(self) weakSelf = self;
        _labelTitle = ^(UILabel *labelTitle) {
            weakSelf.alertView.labelTitle = labelTitle;
            return weakSelf;
        };
    }
    return _labelTitle;
}
- (NVAlertViewBuilder *(^) (UITextView *viewText))viewText {
    if (!_viewText) {
        __weak typeof(self) weakSelf = self;
        _viewText = ^(UITextView *viewText) {
            weakSelf.alertView.viewText = viewText;
            return weakSelf;
        };
    }
    return _viewText;
}
- (NVAlertViewBuilder *(^) (UIActivityIndicatorView *activityIndicatorView))activityIndicatorView {
    if (!_activityIndicatorView) {
        __weak typeof(self) weakSelf = self;
        _activityIndicatorView = ^(UIActivityIndicatorView *activityIndicatorView) {
            weakSelf.alertView.activityIndicatorView = activityIndicatorView;
            return weakSelf;
        };
    }
    return _activityIndicatorView;
}
- (NVAlertViewBuilder *(^) (BOOL shouldDismissOnTapOutside))shouldDismissOnTapOutside {
    if (!_shouldDismissOnTapOutside) {
        __weak typeof(self) weakSelf = self;
        _shouldDismissOnTapOutside = ^(BOOL shouldDismissOnTapOutside) {
            weakSelf.alertView.shouldDismissOnTapOutside = shouldDismissOnTapOutside;
            return weakSelf;
        };
    }
    return _shouldDismissOnTapOutside;
}
- (NVAlertViewBuilder *(^) (NSURL *soundURL))soundURL {
    if (!_soundURL) {
        __weak typeof(self) weakSelf = self;
        _soundURL = ^(NSURL *soundURL) {
            weakSelf.alertView.soundURL = soundURL;
            return weakSelf;
        };
    }
    return _soundURL;
}
- (NVAlertViewBuilder *(^) (NVAttributedFormatBlock attributedFormatBlock))attributedFormatBlock {
    if (!_attributedFormatBlock) {
        __weak typeof(self) weakSelf = self;
        _attributedFormatBlock = ^(NVAttributedFormatBlock attributedFormatBlock) {
            weakSelf.alertView.attributedFormatBlock = attributedFormatBlock;
            return weakSelf;
        };
    }
    return _attributedFormatBlock;
}
- (NVAlertViewBuilder *(^) (CompleteButtonFormatBlock completeButtonFormatBlock))completeButtonFormatBlock {
    if (!_completeButtonFormatBlock) {
        __weak typeof(self) weakSelf = self;
        _completeButtonFormatBlock = ^(CompleteButtonFormatBlock completeButtonFormatBlock) {
            weakSelf.alertView.completeButtonFormatBlock = completeButtonFormatBlock;
            return weakSelf;
        };
    }
    return _completeButtonFormatBlock;
}
- (NVAlertViewBuilder *(^) (ButtonFormatBlock buttonFormatBlock))buttonFormatBlock {
    if (!_buttonFormatBlock) {
        __weak typeof(self) weakSelf = self;
        _buttonFormatBlock = ^(ButtonFormatBlock buttonFormatBlock) {
            weakSelf.alertView.buttonFormatBlock = buttonFormatBlock;
            return weakSelf;
        };
    }
    return _buttonFormatBlock;
}
- (NVAlertViewBuilder *(^) (NVForceHideBlock forceHideBlock))forceHideBlock {
    if (!_forceHideBlock) {
        __weak typeof(self) weakSelf = self;
        _forceHideBlock = ^(NVForceHideBlock forceHideBlock) {
            weakSelf.alertView.forceHideBlock = forceHideBlock;
            return weakSelf;
        };
    }
    return _forceHideBlock;
}
- (NVAlertViewBuilder *(^) (NVAlertViewHideAnimation hideAnimationType))hideAnimationType {
    if (!_hideAnimationType) {
        __weak typeof(self) weakSelf = self;
        _hideAnimationType = ^(NVAlertViewHideAnimation hideAnimationType) {
            weakSelf.alertView.hideAnimationType = hideAnimationType;
            return weakSelf;
        };
    }
    return _hideAnimationType;
}
- (NVAlertViewBuilder *(^) (NVAlertViewShowAnimation showAnimationType))showAnimationType {
    if (!_showAnimationType) {
        __weak typeof(self) weakSelf = self;
        _showAnimationType = ^(NVAlertViewShowAnimation showAnimationType) {
            weakSelf.alertView.showAnimationType = showAnimationType;
            return weakSelf;
        };
    }
    return _showAnimationType;
}
- (NVAlertViewBuilder *(^) (NVAlertViewBackground backgroundType))backgroundType {
    if (!_backgroundType) {
        __weak typeof(self) weakSelf = self;
        _backgroundType = ^(NVAlertViewBackground backgroundType) {
            weakSelf.alertView.backgroundType = backgroundType;
            return weakSelf;
        };
    }
    return _backgroundType;
}
- (NVAlertViewBuilder *(^) (UIColor *customViewColor))customViewColor {
    if (!_customViewColor) {
        __weak typeof(self) weakSelf = self;
        _customViewColor = ^(UIColor *customViewColor) {
            weakSelf.alertView.customViewColor = customViewColor;
            return weakSelf;
        };
    }
    return _customViewColor;
}
- (NVAlertViewBuilder *(^) (UIColor *backgroundViewColor))backgroundViewColor {
    if (!_backgroundViewColor) {
        __weak typeof(self) weakSelf = self;
        _backgroundViewColor = ^(UIColor *backgroundViewColor) {
            weakSelf.alertView.backgroundViewColor = backgroundViewColor;
            return weakSelf;
        };
    }
    return _backgroundViewColor;
}
- (NVAlertViewBuilder *(^) (UIColor *iconTintColor))iconTintColor {
    if (!_iconTintColor) {
        __weak typeof(self) weakSelf = self;
        _iconTintColor = ^(UIColor *iconTintColor) {
            weakSelf.alertView.iconTintColor = iconTintColor;
            return weakSelf;
        };
    }
    return _iconTintColor;
}
- (NVAlertViewBuilder *(^) (CGFloat circleIconHeight))circleIconHeight {
    if (!_circleIconHeight) {
        __weak typeof(self) weakSelf = self;
        _circleIconHeight = ^(CGFloat circleIconHeight) {
            weakSelf.alertView.circleIconHeight = circleIconHeight;
            return weakSelf;
        };
    }
    return _circleIconHeight;
}
- (NVAlertViewBuilder *(^) (CGRect extensionBounds))extensionBounds {
    if (!_extensionBounds) {
        __weak typeof(self) weakSelf = self;
        _extensionBounds = ^(CGRect extensionBounds) {
            weakSelf.alertView.extensionBounds = extensionBounds;
            return weakSelf;
        };
    }
    return _extensionBounds;
}
- (NVAlertViewBuilder *(^) (BOOL statusBarHidden))statusBarHidden {
    if (!_statusBarHidden) {
        __weak typeof(self) weakSelf = self;
        _statusBarHidden = ^(BOOL statusBarHidden) {
            weakSelf.alertView.statusBarHidden = statusBarHidden;
            return weakSelf;
        };
    }
    return _statusBarHidden;
}
- (NVAlertViewBuilder *(^) (UIStatusBarStyle statusBarStyle))statusBarStyle {
    if (!_statusBarStyle) {
        __weak typeof(self) weakSelf = self;
        _statusBarStyle = ^(UIStatusBarStyle statusBarStyle) {
            weakSelf.alertView.statusBarStyle = statusBarStyle;
            return weakSelf;
        };
    }
    return _statusBarStyle;
}

#pragma mark - Custom Setters
- (NVAlertViewBuilder *(^) (NVDismissBlock dismissBlock))alertIsDismissed {
    if (!_alertIsDismissed) {
        __weak typeof(self) weakSelf = self;
        _alertIsDismissed = ^(NVDismissBlock dismissBlock) {
            [weakSelf.alertView alertIsDismissed:dismissBlock];
            return weakSelf;
        };
    }
    return _alertIsDismissed;
}
-(NVAlertViewBuilder *(^)(NVDismissAnimationCompletionBlock))alertDismissAnimationIsCompleted{
    if (!_alertDismissAnimationIsCompleted) {
        __weak typeof(self) weakSelf = self;
        _alertDismissAnimationIsCompleted = ^(NVDismissAnimationCompletionBlock dismissAnimationCompletionBlock) {
            [weakSelf.alertView alertDismissAnimationIsCompleted:dismissAnimationCompletionBlock];
            return weakSelf;
        };
    }
    return _alertDismissAnimationIsCompleted;
}
-(NVAlertViewBuilder *(^)(NVShowAnimationCompletionBlock))alertShowAnimationIsCompleted{
    if (!_alertShowAnimationIsCompleted) {
        __weak typeof(self) weakSelf = self;
        _alertShowAnimationIsCompleted = ^(NVShowAnimationCompletionBlock showAnimationCompletionBlock) {
            [weakSelf.alertView alertShowAnimationIsCompleted:showAnimationCompletionBlock];
            return weakSelf;
        };
    }
    return _alertShowAnimationIsCompleted;
}
- (NVAlertViewBuilder *(^) (void))removeTopCircle {
    if (!_removeTopCircle) {
        __weak typeof(self) weakSelf = self;
        _removeTopCircle = ^(void) {
            [weakSelf.alertView removeTopCircle];
            return weakSelf;
        };
    }
    return _removeTopCircle;
}



//添加自定义视图方式
- (NVAlertViewBuilder *(^) (UIView *view))addCustomView {
    if (!_addCustomView) {
        __weak typeof(self) weakSelf = self;
        _addCustomView = ^(UIView *view) {
            [weakSelf.alertView addCustomView:view];
            return weakSelf;
        };
    }
    return _addCustomView;
}




- (NVAlertViewBuilder *(^) (NSString *title))addTextField {
    if (!_addTextField) {
        __weak typeof(self) weakSelf = self;
        _addTextField = ^(NSString *title) {
            [weakSelf.alertView addTextField:title];
            return weakSelf;
        };
    }
    return _addTextField;
}
- (NVAlertViewBuilder *(^) (UITextField *textField))addCustomTextField {
    if (!_addCustomTextField) {
        __weak typeof(self) weakSelf = self;
        _addCustomTextField = ^(UITextField *textField) {
            [weakSelf.alertView addCustomTextField:textField];
            return weakSelf;
        };
    }
    return _addCustomTextField;
}
- (NVAlertViewBuilder *(^) (NSString *title))addSwitchViewWithLabelTitle {
    if (!_addSwitchViewWithLabelTitle) {
        __weak typeof(self) weakSelf = self;
        _addSwitchViewWithLabelTitle = ^(NSString *title) {
            [weakSelf.alertView addSwitchViewWithLabel:title];
            return weakSelf;
        };
    }
    return _addSwitchViewWithLabelTitle;
}
- (NVAlertViewBuilder *(^) (NSInteger buttonIndex, BOOL reverse))addTimerToButtonIndex {
    if (!_addTimerToButtonIndex) {
        __weak typeof(self) weakSelf = self;
        _addTimerToButtonIndex = ^(NSInteger buttonIndex, BOOL reverse) {
            [weakSelf.alertView addTimerToButtonIndex:buttonIndex reverse:reverse];
            return weakSelf;
        };
    }
    return _addTimerToButtonIndex;
}
- (NVAlertViewBuilder *(^) (NSString *titleFontFamily, CGFloat size))setTitleFontFamily {
    if (!_setTitleFontFamily) {
        __weak typeof(self) weakSelf = self;
        _setTitleFontFamily = ^(NSString *titleFontFamily, CGFloat size) {
            [weakSelf.alertView setTitleFontFamily:titleFontFamily withSize:size];
            return weakSelf;
        };
    }
    return _setTitleFontFamily;
}
- (NVAlertViewBuilder *(^) (NSString *bodyTextFontFamily, CGFloat size))setBodyTextFontFamily {
    if (!_setBodyTextFontFamily) {
        __weak typeof(self) weakSelf = self;
        _setBodyTextFontFamily = ^(NSString *bodyTextFontFamily, CGFloat size) {
            [weakSelf.alertView setBodyTextFontFamily:bodyTextFontFamily withSize:size];
            return weakSelf;
        };
    }
    return _setBodyTextFontFamily;
}
- (NVAlertViewBuilder *(^) (NSString *buttonsFontFamily, CGFloat size))setButtonsTextFontFamily {
    if (!_setButtonsTextFontFamily) {
        __weak typeof(self) weakSelf = self;
        _setButtonsTextFontFamily = ^(NSString *buttonsFontFamily, CGFloat size) {
            [weakSelf.alertView setButtonsTextFontFamily:buttonsFontFamily withSize:size];
            return weakSelf;
        };
    }
    return _setButtonsTextFontFamily;
}
- (NVAlertViewBuilder *(^) (NSString *title, NVActionBlock action))addButtonWithActionBlock {
    if (!_addButtonWithActionBlock) {
        __weak typeof(self) weakSelf = self;
        _addButtonWithActionBlock = ^(NSString *title, NVActionBlock action) {
            [weakSelf.alertView addButton:title actionBlock:action];
            return weakSelf;
        };
    }
    return _addButtonWithActionBlock;
}
- (NVAlertViewBuilder *(^) (NSString *title, NVValidationBlock validationBlock, NVActionBlock action))addButtonWithValidationBlock {
    if (!_addButtonWithValidationBlock) {
        __weak typeof(self) weakSelf = self;
        _addButtonWithValidationBlock = ^(NSString *title, NVValidationBlock validationBlock, NVActionBlock action) {
            [weakSelf.alertView addButton:title validationBlock:validationBlock actionBlock:action];
            return weakSelf;
        };
    }
    return _addButtonWithValidationBlock;
}
- (NVAlertViewBuilder *(^) (NSString *title, id target, SEL selector))addButtonWithTarget {
    if (!_addButtonWithTarget) {
        __weak typeof(self) weakSelf = self;
        _addButtonWithTarget = ^(NSString *title, id target, SEL selector) {
            [weakSelf.alertView addButton:title target:target selector:selector];
            return weakSelf;
        };
    }
    return _addButtonWithTarget;
}

#pragma mark - Builders
- (NVAlertViewBuilder *(^)(NVALertViewButtonBuilder *builder))addButtonWithBuilder {
    if (!_addButtonWithBuilder) {
        __weak typeof(self) weakSelf = self;
        _addButtonWithBuilder = ^(NVALertViewButtonBuilder *builder){
            NVButton *button = nil;
            if (builder.parameterTarget && builder.parameterSelector) {
                button = [weakSelf.alertView addButton:builder.parameterTitle target:builder.parameterTarget selector:builder.parameterSelector];
            }
            else if (builder.parameterValidationBlock && builder.parameterActionBlock) {
                button = [weakSelf.alertView addButton:builder.parameterTitle validationBlock:builder.parameterValidationBlock actionBlock:builder.parameterActionBlock];
            }
            else if (builder.parameterActionBlock) {
                button = [weakSelf.alertView addButton:builder.parameterTitle actionBlock:builder.parameterActionBlock];
            }
            builder.button = button;
            return weakSelf; 
        };
    }
    return _addButtonWithBuilder;
}
- (NVAlertViewBuilder *(^)(NVALertViewTextFieldBuilder *builder))addTextFieldWithBuilder {
    if (!_addTextFieldWithBuilder) {
        __weak typeof(self) weakSelf = self;
        _addTextFieldWithBuilder = ^(NVALertViewTextFieldBuilder *builder){
            builder.textField = [weakSelf.alertView addTextField:builder.parameterTitle];
            return weakSelf;
        };
    }
    return _addTextFieldWithBuilder;
}
@end

@interface NVAlertViewShowBuilder()

@property(weak, nonatomic) UIViewController *parameterViewController;
@property(copy, nonatomic) UIImage *parameterImage;
@property(copy, nonatomic) UIColor *parameterColor;
@property(copy, nonatomic) NSString *parameterTitle;
@property(copy, nonatomic) NSString *parameterSubTitle;
@property(copy, nonatomic) NSString *parameterCompleteText;
@property(copy, nonatomic) NSString *parameterCloseButtonTitle;
@property(assign, nonatomic) NVAlertViewStyle parameterStyle;
@property(assign, nonatomic) NSTimeInterval parameterDuration;

#pragma mark - Setters
@property(copy, nonatomic) NVAlertViewShowBuilder *(^viewController)(UIViewController *viewController);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^image)(UIImage *image);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^color)(UIColor *color);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^title)(NSString *title);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^subTitle)(NSString *subTitle);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^completeText)(NSString *completeText);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^style)(NVAlertViewStyle style);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^closeButtonTitle)(NSString *closeButtonTitle);
@property(copy, nonatomic) NVAlertViewShowBuilder *(^duration)(NSTimeInterval duration);

#pragma mark - Show
@property(copy, nonatomic) void (^show)(NVAlertView *view, UIViewController *controller);
@end

@implementation NVAlertViewShowBuilder


#pragma mark - Setters
- (NVAlertViewShowBuilder *(^)(UIViewController *viewController))viewController {
    if (!_viewController) {
        __weak typeof(self) weakSelf = self;
        _viewController = ^(UIViewController *viewController){
            weakSelf.parameterViewController = viewController;
            return weakSelf;
        };
    }
    return _viewController;
}
- (NVAlertViewShowBuilder *(^)(UIImage *image))image {
    if (!_image) {
        __weak typeof(self) weakSelf = self;
        _image = ^(UIImage *image) {
            weakSelf.parameterImage = image;
            return weakSelf;
        };
    }
    return _image;
}
- (NVAlertViewShowBuilder *(^)(UIColor *color))color {
    if (!_color) {
        __weak typeof(self) weakSelf = self;
        _color = ^(UIColor *color) {
            weakSelf.parameterColor = color;
            return weakSelf;
        };
    }
    return _color;
}
- (NVAlertViewShowBuilder *(^)(NSString *title))title {
    if (!_title) {
        __weak typeof(self) weakSelf = self;
        _title = ^(NSString *title){
            weakSelf.parameterTitle = title;
            return weakSelf;
        };
    }
    return _title;
}
- (NVAlertViewShowBuilder *(^)(NSString *subTitle))subTitle {
    if (!_subTitle) {
        __weak typeof(self) weakSelf = self;
        _subTitle = ^(NSString *subTitle){
            weakSelf.parameterSubTitle = subTitle;
            return weakSelf;
        };
    }
    return _subTitle;
}
- (NVAlertViewShowBuilder *(^)(NSString *completeText))completeText {
    if (!_completeText) {
        __weak typeof(self) weakSelf = self;
        _completeText = ^(NSString *completeText){
            weakSelf.parameterCompleteText = completeText;
            return weakSelf;
        };
    }
    return _completeText;
}

- (NVAlertViewShowBuilder *(^)(NVAlertViewStyle style))style {
    if (!_style) {
        __weak typeof(self) weakSelf = self;
        _style = ^(NVAlertViewStyle style){
            weakSelf.parameterStyle = style;
            return weakSelf;
        };
    }
    return _style;
}
- (NVAlertViewShowBuilder *(^)(NSString *closeButtonTitle))closeButtonTitle {
    if (!_closeButtonTitle) {
        __weak typeof(self) weakSelf = self;
        _closeButtonTitle = ^(NSString *closeButtonTitle){
            weakSelf.parameterCloseButtonTitle = closeButtonTitle;
            return weakSelf;
        };
    }
    return _closeButtonTitle;
}
- (NVAlertViewShowBuilder *(^)(NSTimeInterval duration))duration {
    if (!_duration) {
        __weak typeof(self) weakSelf = self;
        _duration = ^(NSTimeInterval duration){
            weakSelf.parameterDuration = duration;
            return weakSelf;
        };
    }
    return _duration;
}

- (void)showAlertView:(NVAlertView *)alertView {
    [self showAlertView:alertView onViewController:self.parameterViewController];
}

- (void)showAlertView:(NVAlertView *)alertView onViewController:(UIViewController *)controller {
    UIViewController *targetController = controller ? controller : self.parameterViewController;
    
    if (self.parameterImage || self.parameterColor) {
        [alertView showTitle:targetController image:self.parameterImage color:self.parameterColor title:self.parameterTitle subTitle:self.parameterSubTitle duration:self.parameterDuration completeText:self.parameterCloseButtonTitle style:self.parameterStyle];
    }
    else {
        [alertView showTitle:targetController title:self.parameterTitle subTitle:self.parameterSubTitle style:self.parameterStyle closeButtonTitle:self.parameterCloseButtonTitle duration:self.parameterDuration];
    }
}

- (void (^)(NVAlertView *view, UIViewController *controller))show {
    if (!_show) {
        __weak typeof(self) weakSelf = self;
        _show = ^(NVAlertView *view, UIViewController *controller) {
            [weakSelf showAlertView:view onViewController:controller];
        };
    }
    return _show;
}

@end
