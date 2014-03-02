//
//  PPLogger.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PPLogCrit(frmt, ...)    PPLog(PPLoggerFlagCrit,     frmt, ##__VA_ARGS__)
#define PPLogError(frmt, ...)   PPLog(PPLoggerFlagError,    frmt, ##__VA_ARGS__)
#define PPLogWarn(frmt, ...)    PPLog(PPLoggerFlagWarn,     frmt, ##__VA_ARGS__)
#define PPLogInfo(frmt, ...)    PPLog(PPLoggerFlagInfo,     frmt, ##__VA_ARGS__)
#define PPLogDebug(frmt, ...)   PPLog(PPLoggerFlagDebug,    frmt, ##__VA_ARGS__)
#define PPLogVerbose(frmt, ...) PPLog(PPLoggerFlagVerbose,  frmt, ##__VA_ARGS__)

#define PPSetLogLevel(level) ([[[PPSdk sharedSdk] logger] setLogLevel:level])

#define PPLog(flag, frmt, ...)                                  \
    [[[PPSdk sharedSdk] logger] logFlag:flag                    \
                                   file:__FILE__                \
                               function:__PRETTY_FUNCTION__     \
                                   line:__LINE__                \
                                 format:(frmt), ##__VA_ARGS__]

/** Defines the flag for each log type */
typedef NS_ENUM(NSUInteger, PPLoggerFlag) {
    PPLoggerFlagCrit    = (1 << 0),  // 0...000001
    PPLoggerFlagError   = (1 << 1),  // 0...000010
    PPLoggerFlagWarn    = (1 << 2),  // 0...000100
    PPLoggerFlagInfo    = (1 << 3),  // 0...001000
    PPLoggerFlagDebug   = (1 << 4),  // 0...010000
    PPLoggerFlagVerbose = (1 << 5),  // 0...100000
};

/** Defines the bitmask for enabled log types */
typedef NS_ENUM(NSUInteger, PPLoggerLevel) {
    PPLoggerLevelOff        = 0,                                            // 0...000000
    
    PPLoggerLevelCrit       = (PPLoggerFlagCrit),                           // 0...000001
    
    PPLoggerLevelError      = (PPLoggerFlagCrit | PPLoggerFlagError),       // 0...000011
    
    PPLoggerLevelWarn       = (PPLoggerFlagCrit | PPLoggerFlagError |
                               PPLoggerFlagWarn),                           // 0...000111
    
    PPLoggerLevelInfo       = (PPLoggerFlagCrit | PPLoggerFlagError |
                               PPLoggerFlagWarn | PPLoggerFlagInfo),        // 0...001111
    
    PPLoggerLevelDebug      = (PPLoggerFlagCrit | PPLoggerFlagError |
                               PPLoggerFlagWarn | PPLoggerFlagInfo |
                               PPLoggerFlagDebug),                          // 0...011111
    
    PPLoggerLevelVerbose    = (PPLoggerFlagCrit | PPLoggerFlagError |
                               PPLoggerFlagWarn | PPLoggerFlagInfo |
                               PPLoggerFlagDebug | PPLoggerFlagVerbose),    // 0...111111
};

/**
 Common superclass for all logger implementations
 
 Has a changeable log level, and knows how to log a certain log message
 */
@interface PPLogger : NSObject

/**
 Log level used.
 
 All log messages with log type higher than log level aren't logged 
 */
@property (nonatomic, assign) PPLoggerLevel logLevel;

/**
 Performs the actual logging
 
 This concrete class uses NSLog for logging. Subclasses may override
 */
- (void)logFlag:(PPLoggerFlag)flag
           file:(const char *)file
       function:(const char *)function
           line:(int)line
         format:(NSString *)format, ...;

@end
