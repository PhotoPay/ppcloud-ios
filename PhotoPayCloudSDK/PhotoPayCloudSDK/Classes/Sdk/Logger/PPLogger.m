//
//  PPLogger.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPLogger.h"

@implementation PPLogger

- (id)init {
    self = [super init];
    if (self) {
        _logLevel = PPLogLevelVerbose;
    }
    return self;
}

- (void)logFlag:(PPLogFlag)flag
           file:(const char *)file
       function:(const char *)function
           line:(int)line
         format:(NSString *)format, ... {
    
    if (flag & [self logLevel]) {
        va_list args;
        if (format) {
            va_start(args, format);
            NSLogv(format, args);
            va_end(args);
        }
    }
}

@end
