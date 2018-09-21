//
//  DatePickerAlertView.m
//  DatePickerAlertView
//
//  Created by SNICE on 2018/8/29.
//  Copyright © 2018年 G. All rights reserved.
//

#import "DatePickerAlertView.h"

@implementation UIView (Frame)

- (void)setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint
{
    CGFloat x = point.x - anchorPoint.x * self.frame.size.width;
    CGFloat y = point.y - anchorPoint.y * self.frame.size.height;
    CGRect frame = self.frame;
    frame.origin = CGPointMake(x, y);
    self.frame = frame;
}

@end

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width      //屏幕宽
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height    //屏幕高

#define ISIPHONEX \
^(){\
BOOL iPhoneX = NO;\
if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {\
return iPhoneX;\
}\
if (@available(iOS 11.0, *)) {\
UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];\
if (mainWindow.safeAreaInsets.bottom > 0.0) {\
iPhoneX = YES;\
}\
}\
return iPhoneX;\
}()

#define STATUS_BAR_HEIGHT                (ISIPHONEX ? 44.0f : 20.0f)
#define NAVIGATION_BAR_HEIGHT            (44.0f)
#define STATUS_AND_NAVIGATION_BAR_HEIGHT ((STATUS_BAR_HEIGHT) + (NAVIGATION_BAR_HEIGHT))
#define k_BOTTOM_SAFE_HEIGHT   (CGFloat)(ISIPHONEX ? (34) : (0)) //iPhone X底部home键高度

#define TIPS_ALERT_DURATION 0.25f        //动画时长
#define SHOW_DURATION       1.5f         //显示时长

@interface TipsAlertView : UIView

@property (nonatomic, strong) NSString *tipsString;
@property (nonatomic, strong, readonly) UILabel *tipsLabel;

@end

@implementation TipsAlertView

+ (void)showWithTips:(NSString *)tips {
    TipsAlertView *alertView = [[TipsAlertView alloc] init];
    alertView.tipsString = tips;
    [alertView setPosition:CGPointZero atAnchorPoint:CGPointMake(0, 1)];
    [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    [alertView show];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, STATUS_AND_NAVIGATION_BAR_HEIGHT);
        self.clipsToBounds = YES;
        
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0, self.frame.size.width - 30.0f, self.frame.size.height)];
        _tipsLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipsLabel.textColor = [UIColor redColor];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.contentMode = UIViewContentModeBottom;
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:_tipsLabel];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)setTipsString:(NSString *)tipsString {
    _tipsString = tipsString;
    _tipsLabel.text = tipsString;
    
    [_tipsLabel sizeToFit];
    [_tipsLabel setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height - 10.0f) atAnchorPoint:CGPointMake(0.5, 1)];
}

- (void)show {
    [UIView animateWithDuration:TIPS_ALERT_DURATION animations:^{
        [self setPosition:CGPointZero atAnchorPoint:CGPointZero];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:SHOW_DURATION];
    }];
}

- (void)hide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:TIPS_ALERT_DURATION animations:^{
        [self setPosition:CGPointZero atAnchorPoint:CGPointMake(0, 1)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

#define HexColor(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]
#define TEXT_COLOR           HexColor(0x111111)    //文本默认显示颜色
#define HIGHLIGHTED_COLOR    HexColor(0x25c97c)    //文本高亮显示颜色
#define BACKGROUNG_COLOR     HexColor(0xf5f7f9)
#define TAG_COLOR            HexColor(0x999999)

#define ANIMATION_DURATION   0.5f      //动画时长
#define WINDOWVIEW_HEIGHT    300.0f    //显示视图高度
#define PICKERVIEW_HEIGHT    200.0f    //时间选择器高度
#define MARGIN               15.0f     //边距
#define LABEL_WIDTH          40.0f     //"至"label宽度
#define TEXTFIELD_WIDTH      ((SCREEN_WIDTH - MARGIN * 2.0f - LABEL_WIDTH) / 2.0f) //textfield宽度
#define TEXTFIELD_HEIGHT     30.0f     //textfield高度
#define BOTTOM_BUTTON_HEIGHT 40.0f     //底部按钮高度
#define BOTTOM_BUTTON_WIDTH  (SCREEN_WIDTH / 2.0f) //底部按钮宽度

#define FROM_TIME_BUTTON_PLACEHOLDER          @"请选择开始时间"
#define TO_TIME_BUTTON_PLACEHOLDER            @"请选择结束时间"
#define FROM_TIME_MORE_THEM_TO_TIME_TIPS      @"开始时间不能大于结束时间"
#define TO_TIME_LESS_THEM_FROM_TIME_TIPS      @"结束时间不能小于开始时间"
#define TO_TIME_IS_EMPTY_TIPS                 @"请选择结束时间"

@interface DatePickerAlertView() <UITextFieldDelegate>

@property (nonatomic, strong) UIWindow *window;                     //window
@property (nonatomic, strong) UIView *blackMask;                    //黑色笼罩
@property (nonatomic, strong) UIView *windowView;                   //显示view

@property (nonatomic, strong) UIDatePicker *datePicker;             //时间选择器

@property (nonatomic, strong) UIButton *fromTimeButton;             //开始时间按钮
@property (nonatomic, strong) UIButton *toTimeButton;               //结束时间按钮

@property (nonatomic, strong) UIButton *resetButton;                //重置按钮
@property (nonatomic, strong) UIButton *ensureButton;               //确定按钮

@property (nonatomic, strong) NSString *dateFormat;                 //时间格式显示
@property (nonatomic, assign) UIDatePickerMode datePickerMode;      //日期控件显示类型

@property (nonatomic, strong) NSDate *fromDate;                     //开始时间
@property (nonatomic, strong) NSDate *toDate;                       //结束时间

@property (nonatomic, strong) void (^didSelectDate)(NSDate *fromDate, NSDate *toDate);

@end

@implementation DatePickerAlertView

+ (void)showDatePickerAlertViewWithSelectCompletion:(void (^)(NSDate *fromDate, NSDate *toDate))selectCompletion {
    [self showDatePickerAlertViewWithDateFormat:D_yyyy_MM_dd datePickerMode:UIDatePickerModeDate selectCompletion:selectCompletion];
}

+ (void)showDatePickerAlertViewWithDateFormat:(NSString *)dateFormat datePickerMode:(UIDatePickerMode)datePickerMode selectCompletion:(void (^)(NSDate *fromDate, NSDate *toDate))selectCompletion {
    DatePickerAlertView *alertView = [[DatePickerAlertView alloc] init];
    alertView.didSelectDate = ^(NSDate *fromDate, NSDate *toDate) {
        if (selectCompletion) selectCompletion(fromDate, toDate);
    };
    alertView.dateFormat = dateFormat;
    alertView.datePickerMode = datePickerMode;
    [alertView resetAction];
    [alertView show];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        [self addSubview:self.blackMask];
        
        [self.windowView setPosition:CGPointMake(0, SCREEN_HEIGHT) atAnchorPoint:CGPointZero];
        [self addSubview:self.windowView];
        
        [self.fromTimeButton setPosition:CGPointMake(MARGIN, MARGIN) atAnchorPoint:CGPointZero];
        [self.windowView addSubview:self.fromTimeButton];
        
        [self.toTimeButton setPosition:CGPointMake(SCREEN_WIDTH - MARGIN, MARGIN) atAnchorPoint:CGPointMake(1, 0)];
        [self.windowView addSubview:self.toTimeButton];
        
        [self.datePicker setPosition:CGPointMake(0, CGRectGetMaxY(self.fromTimeButton.frame) + MARGIN) atAnchorPoint:CGPointZero];
        [self.windowView addSubview:self.datePicker];
        
        [self.resetButton setPosition:CGPointMake(0, WINDOWVIEW_HEIGHT) atAnchorPoint:CGPointMake(0, 1)];
        [self.windowView addSubview:self.resetButton];
        
        [self.ensureButton setPosition:CGPointMake(SCREEN_WIDTH, WINDOWVIEW_HEIGHT) atAnchorPoint:CGPointMake(1, 1)];
        [self.windowView addSubview:self.ensureButton];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGR];
        
        _dateFormat = D_yyyy_MM_dd;
        
        [self resetAction];
    }
    return self;
}

- (void)resetAction {
    self.fromDate = [NSDate date];
    [self.datePicker setDate:self.fromDate animated:YES];
    self.fromTimeButton.selected = YES;
    [self.fromTimeButton setTitle:[self.class dateStringWithDate:_fromDate format:_dateFormat] forState:UIControlStateNormal];
    
    self.toDate = nil;
    self.toTimeButton.selected = NO;
    [self.toTimeButton setTitle:TO_TIME_BUTTON_PLACEHOLDER forState:UIControlStateNormal];
}

- (void)ensureAction {
    if (!self.toDate) {
        [TipsAlertView showWithTips:TO_TIME_IS_EMPTY_TIPS];
        return ;
    }
    if (self.didSelectDate) {
        self.didSelectDate(self.fromDate, self.toDate);
    }
    [self hide];
}

- (void)timeButtonAction {
    self.toTimeButton.selected = self.fromTimeButton.selected;
    self.fromTimeButton.selected = !self.fromTimeButton.selected;
}

- (void)dataPickerChanged:(UIDatePicker *)datePicker {
    NSString *dateString = [self.class dateStringWithDate:datePicker.date format:self.dateFormat];
    if (self.fromTimeButton.selected) {
        if ([self judgeDateIsErrorWithFromDate:datePicker.date toDate:self.toDate]) {
            [datePicker setDate:self.fromDate animated:YES];
            [TipsAlertView showWithTips:FROM_TIME_MORE_THEM_TO_TIME_TIPS];
            return ;
        }
        self.fromDate = datePicker.date;
        [self.fromTimeButton setTitle:dateString forState:UIControlStateNormal];
    } else {
        if ([self judgeDateIsErrorWithFromDate:self.fromDate toDate:datePicker.date]) {
            [datePicker setDate:self.toDate ? self.toDate : self.fromDate animated:YES];
            [TipsAlertView showWithTips:TO_TIME_LESS_THEM_FROM_TIME_TIPS];
            return ;
        }
        self.toDate = datePicker.date;
        [self.toTimeButton setTitle:dateString forState:UIControlStateNormal];
    }
}

+ (NSString *)dateStringWithDate:(NSDate *)date format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

- (BOOL)judgeDateIsErrorWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    if (fromDate && toDate && fromDate.timeIntervalSinceReferenceDate >= toDate.timeIntervalSinceReferenceDate) return YES;
    return NO;
}

- (void)show {
    [self.window addSubview:self];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.blackMask.alpha = 0.2f;
        [self.windowView setPosition:CGPointMake(0, SCREEN_HEIGHT - k_BOTTOM_SAFE_HEIGHT) atAnchorPoint:CGPointMake(0, 1)];
    } completion:^(BOOL finished) {
    }];
}

- (void)hide {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.blackMask.alpha = 0.0f;
        [self.windowView setPosition:CGPointMake(0, SCREEN_HEIGHT) atAnchorPoint:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - setter method

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode {
    _datePickerMode = datePickerMode;
    self.datePicker.datePickerMode = datePickerMode;
}

#pragma mark - Lazy loading

- (UIWindow *)window {
    if (!_window) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

- (UIView *)blackMask {
    if (!_blackMask) {
        _blackMask = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _blackMask.clipsToBounds = YES;
        _blackMask.alpha = 0.0f;
        _blackMask.backgroundColor = [UIColor blackColor];
    }
    return _blackMask;
}

- (UIView *)windowView {
    if (!_windowView) {
        _windowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, WINDOWVIEW_HEIGHT)];
        _windowView.backgroundColor = [UIColor whiteColor];
        _windowView.clipsToBounds = YES;
    }
    return _windowView;
}

- (UIButton *)fromTimeButton {
    if (!_fromTimeButton) {
        _fromTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        [_fromTimeButton setTitle:FROM_TIME_BUTTON_PLACEHOLDER forState:UIControlStateNormal];
        [_fromTimeButton setTitleColor:TAG_COLOR forState:UIControlStateNormal];
        [_fromTimeButton setTitleColor:HIGHLIGHTED_COLOR forState:UIControlStateSelected];
        _fromTimeButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_fromTimeButton addTarget:self action:@selector(timeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TEXTFIELD_WIDTH, 1.0f)];
        lineView.backgroundColor = [UIColor blackColor];
        [lineView setPosition:CGPointMake(0, TEXTFIELD_HEIGHT) atAnchorPoint:CGPointMake(0, 1)];
        [_fromTimeButton addSubview:lineView];
    }
    return _fromTimeButton;
}

- (UIButton *)toTimeButton {
    if (!_toTimeButton) {
        _toTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TEXTFIELD_WIDTH, TEXTFIELD_HEIGHT)];
        [_toTimeButton setTitle:TO_TIME_BUTTON_PLACEHOLDER forState:UIControlStateNormal];
        [_toTimeButton setTitleColor:TAG_COLOR forState:UIControlStateNormal];
        [_toTimeButton setTitleColor:HIGHLIGHTED_COLOR forState:UIControlStateSelected];
        _toTimeButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_toTimeButton addTarget:self action:@selector(timeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TEXTFIELD_WIDTH, 1.0f)];
        lineView.backgroundColor = [UIColor blackColor];
        [lineView setPosition:CGPointMake(0, TEXTFIELD_HEIGHT) atAnchorPoint:CGPointMake(0, 1)];
        [_toTimeButton addSubview:lineView];
    }
    return _toTimeButton;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        //创建一个UIPickView对象
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.frame = CGRectMake(0, 0, SCREEN_WIDTH, PICKERVIEW_HEIGHT);
        //设置背景颜色
        _datePicker.backgroundColor = [UIColor whiteColor];
        //设置本地化支持的语言（在此是中文)
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        //显示方式是只显示年月日
        _datePicker.datePickerMode = UIDatePickerModeDate;
        //监听变化
        [_datePicker addTarget:self action:@selector(dataPickerChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BOTTOM_BUTTON_WIDTH, BOTTOM_BUTTON_HEIGHT)];
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
        [_resetButton setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
        _resetButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _resetButton.backgroundColor = BACKGROUNG_COLOR;
        
        [_resetButton addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

- (UIButton *)ensureButton {
    if (!_ensureButton) {
        _ensureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BOTTOM_BUTTON_WIDTH, BOTTOM_BUTTON_HEIGHT)];
        [_ensureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_ensureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _ensureButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _ensureButton.backgroundColor = HIGHLIGHTED_COLOR;
        
        [_ensureButton addTarget:self action:@selector(ensureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ensureButton;
}

@end
