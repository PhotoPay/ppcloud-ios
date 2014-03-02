//
//  PPLocalizer.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPLocalizer.h"

@implementation PPLocalizer

- (NSString*)localizeString:(NSString*)string {
    return NSLocalizedStringFromTable(string, [self language], s);
}

- (NSString*)localizeFormat:(NSString*)format, ... {
    va_list args;
    NSString* res = nil;
    if (format) {
        va_start(args, format);
        res = [[NSString alloc] initWithFormat:NSLocalizedStringFromTable(format, [self language], s)
                                     arguments:args];
        va_end(args);
    }
    return res;
}

@end
