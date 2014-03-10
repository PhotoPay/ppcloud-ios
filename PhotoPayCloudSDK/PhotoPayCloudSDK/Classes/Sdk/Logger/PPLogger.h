//
//  PPLogger.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Defines the flag for each log type */
typedef NS_ENUM(NSUInteger, PPLogFlag) {
    PPLogFlagCrit    = (1 << 0),  // 0...000001
    PPLogFlagError   = (1 << 1),  // 0...000010
    PPLogFlagWarn    = (1 << 2),  // 0...000100
    PPLogFlagInfo    = (1 << 3),  // 0...001000
    PPLogFlagDebug   = (1 << 4),  // 0...010000
    PPLogFlagVerbose = (1 << 5),  // 0...100000
};

/** Defines the bitmask for enabled log types */
typedef NS_ENUM(NSUInteger, PPLogLevel) {
    PPLogLevelOff        = 0,                                            // 0...000000
    
    PPLogLevelCrit       = (PPLogFlagCrit),                           // 0...000001
    
    PPLogLevelError      = (PPLogFlagCrit | PPLogFlagError),       // 0...000011
    
    PPLogLevelWarn       = (PPLogFlagCrit | PPLogFlagError |
                               PPLogFlagWarn),                           // 0...000111
    
    PPLogLevelInfo       = (PPLogFlagCrit | PPLogFlagError |
                               PPLogFlagWarn | PPLogFlagInfo),        // 0...001111
    
    PPLogLevelDebug      = (PPLogFlagCrit | PPLogFlagError |
                               PPLogFlagWarn | PPLogFlagInfo |
                               PPLogFlagDebug),                          // 0...011111
    
    PPLogLevelVerbose    = (PPLogFlagCrit | PPLogFlagError |
                               PPLogFlagWarn | PPLogFlagInfo |
                               PPLogFlagDebug | PPLogFlagVerbose),    // 0...111111
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
@property (nonatomic, assign) PPLogLevel logLevel;

/**
 Performs the actual logging
 
 This concrete class uses NSLog for logging. Subclasses may override
 */
- (void)logFlag:(PPLogFlag)flag
           file:(const char *)file
       function:(const char *)function
           line:(int)line
         format:(NSString *)format, ...;

@end
