//
//  NSDate+Formatting.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 10/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

- (NSString*)pp_shortRelativeFormattedString {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *diff = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit
                                                   fromDate:self
                                                     toDate:[NSDate date]
                                                    options:kNilOptions];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    NSString* time = [format stringFromDate:self];
    
    NSString* result;
    if (diff.year == 0) {
        if (diff.month == 0) {
            if (diff.week == 0) {
                if (diff.day == 0) {
                    result = [NSString stringWithFormat:@"%@ %@", _(@"PhotoPayToday"), time];
                } else if (diff.day == 1) {
                    result = _(@"PhotoPayYesterday");
                } else if (diff.day == 2) {
                    result = _(@"PhotoPay2DaysAgo");
                } else {
                    result = _(@"PhotoPayThisWeek");
                }
            } else if (diff.week == 1) {
                result = _(@"PhotoPayLastWeek");
            } else {
                result = _(@"PhotoPayThisMonth");
            }
        } else if (diff.month == 1) {
            result = _(@"PhotoPayLastMonth");
        } else {
            result = _(@"PhotoPayThisYear");
        }
    } else if (diff.year == 1) {
        result = _(@"PhotoPayLastYear");
    } else {
        result = __(@"PhotoPayYearsAgo", diff.year);
    }
    
    return result;
}

@end
