//
//  NVAlertView.h
//  NVAlertView
//
//  Created by Diogo Autilio on 9/26/14.
//  Copyright (c) 2014-2016 AnyKey Entertainment. All rights reserved.
//

#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif
#import "NVButton.h"
#import "NVTextView.h"
#import "NVSwitchView.h"

typedef NSAttributedString* (^NVAttributedFormatBlock)(NSString *value);
typedef void (^NVDismissBlock)(void);
typedef void (^NVDismissAnimationCompletionBlock)(void);
typedef void (^NVShowAnimationCompletionBlock)(void);
typedef void (^NVForceHideBlock)(void);

@interface NVAlertView : UIViewController 

/** Alert Styles
 *
 * Set NVAlertView Style
 */
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
    NVAlertViewStyleCustom,
    //gyk
    NVAlertViewStyleCloseButtonUnderBottom
};

/** Alert hide animation styles
 *
 * Set NVAlertView hide animation type.
 */
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

/** Alert show animation styles
 *
 * Set NVAlertView show animation type.
 */
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

/** Alert background styles
 *
 * Set NVAlertView background type.
 */
typedef NS_ENUM(NSInteger, NVAlertViewBackground)
{
    NVAlertViewBackgroundShadow,
    NVAlertViewBackgroundBlur,
    NVAlertViewBackgroundTransparent
};

/** Content view corner radius
 *
 * A float value that replaces the standard content viuew corner radius.
 */
@property CGFloat cornerRadius;

/** Tint top circle
 *
 * A boolean value that determines whether to tint the NVAlertView top circle.
 * (Default: YES)
 */
@property BOOL tintTopCircle;

/** Use larger icon
 *
 * A boolean value that determines whether to make the NVAlertView top circle icon larger.
 * (Default: NO)
 */
@property BOOL useLargerIcon;
    
/** Title Label
 *
 * The text displayed as title.
 */
@property UILabel *labelTitle;

/** Text view with the body message
 *
 * Holds the textview.
 */
@property UITextView *viewText;

/** Activity Indicator
 *
 * Holds the activityIndicator.
 */
@property UIActivityIndicatorView *activityIndicatorView;

/** Dismiss on tap outside
 *
 * A boolean value that determines whether to dismiss when tapping outside the NVAlertView.
 * (Default: NO)
 */
@property (nonatomic, assign) BOOL shouldDismissOnTapOutside;

/** Sound URL
 *
 * Holds the sound NSURL path.
 */
@property (nonatomic, strong) NSURL *soundURL;

/** Set text attributed format block
 *
 * Holds the attributed string.
 */
@property (nonatomic, copy) NVAttributedFormatBlock attributedFormatBlock;

/** Set Complete button format block.
 *
 * Holds the button format block.
 * Support keys : backgroundColor, borderWidth, borderColor, textColor
 */
@property (nonatomic, copy) CompleteButtonFormatBlock completeButtonFormatBlock;

/** Set button format block.
 *
 * Holds the button format block.
 * Support keys : backgroundColor, borderWidth, borderColor, textColor
 */
@property (nonatomic, copy) ButtonFormatBlock buttonFormatBlock;

/** Set force hide block.
 *
 * When set force hideview method invocation.
 */
@property (nonatomic, copy) NVForceHideBlock forceHideBlock;

/** Hide animation type
 *
 * Holds the hide animation type.
 * (Default: FadeOut)
 */
@property (nonatomic) NVAlertViewHideAnimation hideAnimationType;

/** Show animation type
 *
 * Holds the show animation type.
 * (Default: SlideInFromTop)
 */
@property (nonatomic) NVAlertViewShowAnimation showAnimationType;

/** Set NVAlertView background type.
 *
 * NVAlertView background type.
 * (Default: Shadow)
 */
@property (nonatomic) NVAlertViewBackground backgroundType;

/** Set custom color to NVAlertView.
 *
 * NVAlertView custom color.
 * (Buttons, top circle and borders)
 */
@property (nonatomic, strong) UIColor *customViewColor;

/** Set custom color to NVAlertView background.
 *
 * NVAlertView background custom color.
 */
@property (nonatomic, strong) UIColor *backgroundViewColor;

/** Set custom tint color for icon image.
 *
 * NVAlertView icon tint color
 */
@property (nonatomic, strong) UIColor *iconTintColor;

/** Set custom circle icon height.
 *
 * Circle icon height
 */
@property (nonatomic) CGFloat circleIconHeight;

/** Set NVAlertView extension bounds.
 *
 * Set new bounds (EXTENSION ONLY)
 */
@property (nonatomic) CGRect extensionBounds;

/** Set status bar hidden.
 *
 * Status bar hidden
 */
@property (nonatomic) BOOL statusBarHidden;

/** Set status bar style.
 *
 * Status bar style
 */
@property (nonatomic) UIStatusBarStyle statusBarStyle;

/** Set horizontal alignment for buttons
 *
 * Horizontal aligment instead of vertically if YES
 */
@property (nonatomic) BOOL horizontalButtons;

/** Initialize NVAlertView using a new window.
 *
 * Init with new window
 */

- (instancetype)initWithNewWindow;

/** Initialize NVAlertView using a new window.
 *
 * Init with new window with custom width
 */
- (instancetype)initWithNewWindowWidth:(CGFloat)windowWidth;



/** Warns that alerts is gone
 *
 * Warns that alerts is gone using block
 */
- (void)alertIsDismissed:(NVDismissBlock)dismissBlock;

/** Warns that alerts dismiss animation is completed
 *
 * Warns that alerts dismiss animation is completed
 */
- (void)alertDismissAnimationIsCompleted:(NVDismissAnimationCompletionBlock)dismissAnimationCompletionBlock;

/** Warns that alerts show animation is completed
 *
 * Warns that alerts show animation is completed
 */
- (void)alertShowAnimationIsCompleted:(NVShowAnimationCompletionBlock)showAnimationCompletionBlock;

/** Hide NVAlertView
 *
 * Hide NVAlertView using animation and removing from super view.
 */

- (void)hideView;

/** NVAlertView visibility
 *
 * Returns if the alert is visible or not.
 */
- (BOOL)isVisible;

/** Remove Top Circle
 *
 * Remove top circle from NVAlertView.
 */
- (void)removeTopCircle;

/** Add a custom UIView
 *
 * @param customView UIView object to be added above the first NVButton.
 */
- (UIView *)addCustomView:(UIView *)customView;

/** Add Text Field
 *
 * @param title The text displayed on the textfield.
 */
- (NVTextView *)addTextField:(NSString *)title;

/** Add a custom Text Field
 *
 * @param textField The custom textfield provided by the programmer.
 */
- (void)addCustomTextField:(UITextField *)textField;

/** Add a switch view
 *
 * @param label The label displayed for the switch.
 */
- (NVSwitchView *)addSwitchViewWithLabel:(NSString *)label;

/** Add Timer Display
 *
 * @param buttonIndex The index of the button to add the timer display to.
 * @param reverse Convert timer to countdown.
 */
- (void)addTimerToButtonIndex:(NSInteger)buttonIndex reverse:(BOOL)reverse;

/** Set Title font family and size
 *
 * @param titleFontFamily The family name used to displayed the title.
 * @param size Font size.
 */
- (void)setTitleFontFamily:(NSString *)titleFontFamily withSize:(CGFloat)size;

/** Set Text field font family and size
 *
 * @param bodyTextFontFamily The family name used to displayed the text field.
 * @param size Font size.
 */
- (void)setBodyTextFontFamily:(NSString *)bodyTextFontFamily withSize:(CGFloat)size;

/** Set Buttons font family and size
 *
 * @param buttonsFontFamily The family name used to displayed the buttons.
 * @param size Font size.
 */
- (void)setButtonsTextFontFamily:(NSString *)buttonsFontFamily withSize:(CGFloat)size;

/** Add a Button with a title and a block to handle when the button is pressed.
 *
 * @param title The text displayed on the button.
 * @param action A block of code to be executed when the button is pressed.
 */
- (NVButton *)addButton:(NSString *)title actionBlock:(NVActionBlock)action;

/** Add a Button with a title, a block to handle validation, and a block to handle when the button is pressed and validation succeeds.
 *
 * @param title The text displayed on the button.
 * @param validationBlock A block of code that will allow you to validate fields or do any other logic you may want to do to determine if the alert should be dismissed or not. Inside of this block, return a BOOL indicating whether or not the action block should be called and the alert dismissed.
 * @param action A block of code to be executed when the button is pressed and validation passes.
 */
- (NVButton *)addButton:(NSString *)title validationBlock:(NVValidationBlock)validationBlock actionBlock:(NVActionBlock)action;

/** Add a Button with a title, a target and a selector to handle when the button is pressed.
 *
 * @param title The text displayed on the button.
 * @param target Add target for particular event.
 * @param selector A method to be executed when the button is pressed.
 */
- (NVButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector;



/**
 展示底部关闭按钮样式, 不在创建window

 @param vc 需要展示的控制器
 @param title 标题
 @param subTitle 副标题
 @param duration 显示时长
 */

- (void)showCloseButton:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle duration:(NSTimeInterval)duration;


/** Show Success NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showSuccess:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showSuccess:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Error NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showError:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showError:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Notice NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showNotice:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showNotice:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Warning NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showWarning:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showWarning:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Info NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showInfo:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showInfo:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Edit NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showEdit:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showEdit:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Title NVAlertView using a predefined type
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param style One of predefined NVAlertView styles.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showTitle:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle style:(NVAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showTitle:(NSString *)title subTitle:(NSString *)subTitle style:(NVAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Shows a custom NVAlertView without using a predefined type, allowing for a custom image and color to be specified.
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param image A UIImage object to be used as the icon for the alert view.
 * @param color A UIColor object to be used to tint the background of the icon circle and the buttons.
 * @param title The title text of the alert view.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showCustom:(UIViewController *)vc image:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showCustom:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Waiting NVAlertView with UIActityIndicator.
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showWaiting:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showWaiting:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

/** Show Question NVAlertView
 *
 * @param vc The view controller the alert view will be displayed in.
 * @param title The text displayed on the button.
 * @param subTitle The subtitle text of the alert view.
 * @param closeButtonTitle The text for the close button.
 * @param duration The amount of time the alert will remain on screen until it is automatically dismissed. If automatic dismissal is not desired, set to 0.
 */
- (void)showQuestion:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;
- (void)showQuestion:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

@end

@interface NVAlertViewShowBuilder : NSObject

@property(weak, nonatomic, readonly) UIViewController *parameterViewController;
@property(copy, nonatomic, readonly) UIImage *parameterImage;
@property(copy, nonatomic, readonly) UIColor *parameterColor;
@property(copy, nonatomic, readonly) NSString *parameterTitle;
@property(copy, nonatomic, readonly) NSString *parameterSubTitle;
@property(copy, nonatomic, readonly) NSString *parameterCompleteText;
@property(copy, nonatomic, readonly) NSString *parameterCloseButtonTitle;
@property(assign, nonatomic, readonly) NVAlertViewStyle parameterStyle;
@property(assign, nonatomic, readonly) NSTimeInterval parameterDuration;

#pragma mark - Setters
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^viewController)(UIViewController *viewController);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^image)(UIImage *image);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^color)(UIColor *color);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^title)(NSString *title);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^subTitle)(NSString *subTitle);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^completeText)(NSString *completeText);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^style)(NVAlertViewStyle style);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^closeButtonTitle)(NSString *closeButtonTitle);
@property(copy, nonatomic, readonly) NVAlertViewShowBuilder *(^duration)(NSTimeInterval duration);

- (void)showAlertView:(NVAlertView *)alertView;
- (void)showAlertView:(NVAlertView *)alertView onViewController:(UIViewController *)controller;
@property(copy, nonatomic, readonly) void (^show)(NVAlertView *view, UIViewController *controller);
@end

@interface NVALertViewTextFieldBuilder : NSObject

#pragma mark - Available later after adding
@property(weak, nonatomic, readonly) NVTextView *textField;

#pragma mark - Setters
@property(copy, nonatomic, readonly) NVALertViewTextFieldBuilder *(^title) (NSString *title);

@end

@interface NVALertViewButtonBuilder : NSObject

#pragma mark - Available later after adding
@property(weak, nonatomic, readonly) NVButton *button;

#pragma mark - Setters
@property(copy, nonatomic, readonly) NVALertViewButtonBuilder *(^title) (NSString *title);
@property(copy, nonatomic, readonly) NVALertViewButtonBuilder *(^target) (id target);
@property(copy, nonatomic, readonly) NVALertViewButtonBuilder *(^selector) (SEL selector);
@property(copy, nonatomic, readonly) NVALertViewButtonBuilder *(^actionBlock) (void(^actionBlock)(void));
@property(copy, nonatomic, readonly) NVALertViewButtonBuilder *(^validationBlock) (BOOL(^validationBlock)(void));

@end

@interface NVAlertViewBuilder : NSObject

#pragma mark - Parameters
@property (strong, nonatomic, readonly) NVAlertView *alertView;

#pragma mark - Init
- (instancetype)init;
- (instancetype)initWithNewWindow;
- (instancetype)initWithNewWindowWidth:(CGFloat)width;

#pragma mark - Properties
@property(copy, nonatomic) NVAlertViewBuilder *(^cornerRadius) (CGFloat cornerRadius);
@property(copy, nonatomic) NVAlertViewBuilder *(^tintTopCircle) (BOOL tintTopCircle);
@property(copy, nonatomic) NVAlertViewBuilder *(^useLargerIcon) (BOOL useLargerIcon);
@property(copy, nonatomic) NVAlertViewBuilder *(^labelTitle) (UILabel *labelTitle);
@property(copy, nonatomic) NVAlertViewBuilder *(^viewText) (UITextView *viewText);
@property(copy, nonatomic) NVAlertViewBuilder *(^activityIndicatorView) (UIActivityIndicatorView *activityIndicatorView);
@property(copy, nonatomic) NVAlertViewBuilder *(^shouldDismissOnTapOutside) (BOOL shouldDismissOnTapOutside);
@property(copy, nonatomic) NVAlertViewBuilder *(^soundURL) (NSURL *soundURL);
@property(copy, nonatomic) NVAlertViewBuilder *(^attributedFormatBlock) (NVAttributedFormatBlock attributedFormatBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^completeButtonFormatBlock) (CompleteButtonFormatBlock completeButtonFormatBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^buttonFormatBlock) (ButtonFormatBlock buttonFormatBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^forceHideBlock) (NVForceHideBlock forceHideBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^hideAnimationType) (NVAlertViewHideAnimation hideAnimationType);
@property(copy, nonatomic) NVAlertViewBuilder *(^showAnimationType) (NVAlertViewShowAnimation showAnimationType);
@property(copy, nonatomic) NVAlertViewBuilder *(^backgroundType) (NVAlertViewBackground backgroundType);
@property(copy, nonatomic) NVAlertViewBuilder *(^customViewColor) (UIColor *customViewColor);
@property(copy, nonatomic) NVAlertViewBuilder *(^backgroundViewColor) (UIColor *backgroundViewColor);
@property(copy, nonatomic) NVAlertViewBuilder *(^iconTintColor) (UIColor *iconTintColor);
@property(copy, nonatomic) NVAlertViewBuilder *(^circleIconHeight) (CGFloat circleIconHeight);
@property(copy, nonatomic) NVAlertViewBuilder *(^extensionBounds) (CGRect extensionBounds);
@property(copy, nonatomic) NVAlertViewBuilder *(^statusBarHidden) (BOOL statusBarHidden);
@property(copy, nonatomic) NVAlertViewBuilder *(^statusBarStyle) (UIStatusBarStyle statusBarStyle);

#pragma mark - Custom Setters
@property(copy, nonatomic) NVAlertViewBuilder *(^alertIsDismissed) (NVDismissBlock dismissBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^alertDismissAnimationIsCompleted) (NVDismissAnimationCompletionBlock dismissAnimationCompletionBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^alertShowAnimationIsCompleted) (NVShowAnimationCompletionBlock showAnimationCompletionBlock);
@property(copy, nonatomic) NVAlertViewBuilder *(^removeTopCircle)(void);
@property(copy, nonatomic) NVAlertViewBuilder *(^addCustomView)(UIView *view);
@property(copy, nonatomic) NVAlertViewBuilder *(^addTextField)(NSString *title);
@property(copy, nonatomic) NVAlertViewBuilder *(^addCustomTextField)(UITextField *textField);
@property(copy, nonatomic) NVAlertViewBuilder *(^addSwitchViewWithLabelTitle)(NSString *title);
@property(copy, nonatomic) NVAlertViewBuilder *(^addTimerToButtonIndex)(NSInteger buttonIndex, BOOL reverse);
@property(copy, nonatomic) NVAlertViewBuilder *(^setTitleFontFamily)(NSString *titleFontFamily, CGFloat size);
@property(copy, nonatomic) NVAlertViewBuilder *(^setBodyTextFontFamily)(NSString *bodyTextFontFamily, CGFloat size);
@property(copy, nonatomic) NVAlertViewBuilder *(^setButtonsTextFontFamily)(NSString *buttonsFontFamily, CGFloat size);
@property(copy, nonatomic) NVAlertViewBuilder *(^addButtonWithActionBlock)(NSString *title, NVActionBlock action);
@property(copy, nonatomic) NVAlertViewBuilder *(^addButtonWithValidationBlock)(NSString *title, NVValidationBlock validationBlock, NVActionBlock action);
@property(copy, nonatomic) NVAlertViewBuilder *(^addButtonWithTarget)(NSString *title, id target, SEL selector);

#pragma mark - Builders
@property(copy, nonatomic) NVAlertViewBuilder *(^addButtonWithBuilder)(NVALertViewButtonBuilder *builder);
@property(copy, nonatomic) NVAlertViewBuilder *(^addTextFieldWithBuilder)(NVALertViewTextFieldBuilder *builder);

@end
