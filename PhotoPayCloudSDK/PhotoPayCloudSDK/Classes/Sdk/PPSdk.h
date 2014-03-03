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
