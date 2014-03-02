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
