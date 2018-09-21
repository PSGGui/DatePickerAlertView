//
//  DatePickerAlertView.h
//  DatePickerAlertView
//
//  Created by SNICE on 2018/8/29.
//  Copyright © 2018年 G. All rights reserved.
//

#import <UIKit/UIKit.h>

#define D_yyyyMMddHHmmss    @"yyyy-MM-dd HH:mm:ss"      //时间标准模式——1.年-月-日 小时:分钟:秒钟
#define D_yyyyMMddHHmm      @"yyyy-MM-dd HH:mm"         //时间标准模式——2.年-月-日 小时:分钟
#define D_MMddHHmm          @"MM-dd HH:mm"              //时间标准模式-—3.月/日 小时:分钟
#define D_yyyyMMdd          @"yyyy年MM月dd日"            //时间标准模式——4.年月日
#define D_yyyy_MM_dd        @"yyyy-MM-dd"               //时间标准模式——5.年-月-日
#define D_HHmm              @"HH:mm"                    //时间标准模式——6.小时:分钟

@interface DatePickerAlertView : UIView

/**
 显示时间选择器

 @param selectCompletion 完成回调
 */
+ (void)showDatePickerAlertViewWithSelectCompletion:(void (^)(NSDate *fromDate, NSDate *toDate))selectCompletion;

/**
 显示时间选择器(带时间格式，选择器类型)

 @param dateFormat 时间格式
 @param datePickerMode 选择器类型
 @param selectCompletion 完成回调
 */
+ (void)showDatePickerAlertViewWithDateFormat:(NSString *)dateFormat datePickerMode:(UIDatePickerMode)datePickerMode selectCompletion:(void (^)(NSDate *fromDate, NSDate *toDate))selectCompletion;

/**
 日期转换

 @param date 日期
 @param format 日期格式
 @return 日期字符串
 */
+ (NSString *)dateStringWithDate:(NSDate *)date format:(NSString *)format;

@end
