//
//  PPLocalizer.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Common superclass for all localizer implementations
 
 Has a changeable language, and knows how to obtain localized messages
 */
@interface PPLocalizer : NSObject

/**
 Currently used language in the SDK
 */
@property (nonatomic, strong) NSString* language;

/** 
 Finds a localized version of a given string
 */
- (NSString*)localizeString:(NSString*)string;

/**
 Finds a localized version of a given string format
 */
- (NSString*)localizeFormat:(NSString*)format, ...;

@end
