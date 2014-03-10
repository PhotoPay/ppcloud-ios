//
//  PPSdk.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPLogger.h"
#import "PPLocalizer.h"

// iOS Version checking macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IOS7_DEVICE (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))

// iPad/iPhone shortcuts
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (!IS_IPAD)
#define IS_RETINA ([UIScreen mainScreen].scale == 2.0)

#define PPLogCrit(frmt, ...)    PPLog(PPLogFlagCrit,     frmt, ##__VA_ARGS__)
#define PPLogError(frmt, ...)   PPLog(PPLogFlagError,    frmt, ##__VA_ARGS__)
#define PPLogWarn(frmt, ...)    PPLog(PPLogFlagWarn,     frmt, ##__VA_ARGS__)
#define PPLogInfo(frmt, ...)    PPLog(PPLogFlagInfo,     frmt, ##__VA_ARGS__)
#define PPLogDebug(frmt, ...)   PPLog(PPLogFlagDebug,    frmt, ##__VA_ARGS__)
#define PPLogVerbose(frmt, ...) PPLog(PPLogFlagVerbose,  frmt, ##__VA_ARGS__)

#define PPSetLogLevel(level)    ([[[PPSdk sharedSdk] logger] setLogLevel:level])

#define PPLog(flag, frmt, ...)                                  \
    [[[PPSdk sharedSdk] logger] logFlag:flag                    \
                                   file:__FILE__                \
                               function:__PRETTY_FUNCTION__     \
                                   line:__LINE__                \
                                 format:(frmt), ##__VA_ARGS__]

#ifndef PPSetLanguage
#define PPSetLanguage(l) ([[[PPSdk sharedSdk] localizer] setLanguage:l])
#endif

#ifndef PPLocalize
#define PPLocalize(s) ([[[PPSdk sharedSdk] localizer] localizeString:(s)])
#endif

#ifndef PPLocalizeFormat
#define PPLocalizeFormat(frmt, ...) ([[[PPSdk sharedSdk] localizer] localizeFormat:(frmt), ##__VA_ARGS__])
#endif

/**
 Class with common setting for the entire SDK
 */
@interface PPSdk : NSObject

/**
 Logger instance. Can be changed in runtime.
 */
@property (nonatomic, strong) PPLogger* logger;

/**
 Localizer instance. Can be changed in runtime.
 */
@property (nonatomic, strong) PPLocalizer* localizer;

/**
 Shared singleton SDK object
 */
+ (PPSdk*)sharedSdk;

@end
