//
//  PPCocoaLumberjackLogger.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 02/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPLumberjackLogger.h"

@implementation PPLumberjackLogger

- (void)logFlag:(PPLoggerFlag)flag
           file:(const char *)file
       function:(const char *)function
           line:(int)line
         format:(NSString *)format, ... {
    
    int ddflag = LOG_FLAG_ERROR;
    bool async = YES;
    
    switch (flag) {
        case PPLoggerFlagCrit:
        case PPLoggerFlagError:
            ddflag = LOG_FLAG_ERROR;
            async = LOG_ASYNC_ERROR;
            break;
        case PPLoggerFlagWarn:
            ddflag = LOG_FLAG_WARN;
            async = LOG_ASYNC_WARN;
            break;
        case PPLoggerFlagVerbose:
            ddflag = LOG_FLAG_VERBOSE;
            async = LOG_ASYNC_WARN;
            break;
        case PPLoggerFlagInfo:
            ddflag = LOG_FLAG_INFO;
            async = LOG_ASYNC_INFO;
            break;
        case PPLoggerFlagDebug:
        default:
            ddflag = LOG_FLAG_INFO;
            async = LOG_ASYNC_INFO;
            break;
    }
    
    if (ddflag & ddLogLevel) {
        va_list args;
        if (format) {
            va_start(args, format);
            
            [DDLog log:async
                 level:ddLogLevel
                  flag:ddflag
               context:0
                  file:file
              function:function
                  line:line
                   tag:nil
                format:format
                  args:args];
            
            va_end(args);
        }
    }
}

@end
