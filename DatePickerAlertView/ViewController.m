//
//  ViewController.m
//  DatePickerAlertView
//
//  Created by SNICE on 2018/8/29.
//  Copyright © 2018年 G. All rights reserved.
//

#import "ViewController.h"
#import "DatePickerAlertView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fromTimeLB;
@property (weak, nonatomic) IBOutlet UILabel *toTimeLB;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clicked:(UIButton *)sender {
    [DatePickerAlertView showDatePickerAlertViewWithDateFormat:sender.currentTitle
                                                datePickerMode:[@{D_yyyyMMddHHmmss : @(UIDatePickerModeDateAndTime),
                                                                  D_yyyy_MM_dd : @(UIDatePickerModeDate),
                                                                  D_HHmm : @(UIDatePickerModeTime)
                                                                  }[sender.currentTitle] integerValue]
                                              selectCompletion:^(NSDate *fromDate, NSDate *toDate) {
        self.fromTimeLB.text = [DatePickerAlertView dateStringWithDate:fromDate format:sender.currentTitle];
        self.toTimeLB.text = [DatePickerAlertView dateStringWithDate:toDate format:sender.currentTitle];
    }];
//    [DatePickerAlertView showDatePickerAlertViewWithSelectCompletion:^(NSDate *fromDate, NSDate *toDate) {
//        self.fromTimeLB.text = [DatePickerAlertView dateStringWithDate:fromDate format:D_yyyy_MM_dd];
//        self.toTimeLB.text = [DatePickerAlertView dateStringWithDate:toDate format:D_yyyy_MM_dd];
//    }];
}

@end
