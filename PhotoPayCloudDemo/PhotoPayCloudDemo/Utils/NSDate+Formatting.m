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
    
    if (diff.year == 0) {
        if (diff.month == 0) {
            if (diff.week == 0) {
                if (diff.day == 0) {
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"HH:mm"];
                    return [format stringFromDate:self];
                } else if (diff.day == 1) {
                    return _(@"PhotoPayYesterday");
                } else if (diff.day == 2) {
                    return _(@"PhotoPay2DaysAgo");
                } else {
                    return _(@"PhotoPayThisWeek");
                }
            } else if (diff.week == 1) {
                return _(@"PhotoPayLastWeek");
            } else {
                return _(@"PhotoPayThisMonth");
            }
        } else if (diff.month == 1) {
            return _(@"PhotoPayLastMonth");
        } else {
            return _(@"PhotoPayThisYear");
        }
    } else if (diff.year == 1) {
        return _(@"PhotoPayLastYear");
    } else {
        return __(@"PhotoPayYearsAgo", diff.year);
    }
}

@end
