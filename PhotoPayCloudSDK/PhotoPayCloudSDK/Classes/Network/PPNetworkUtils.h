//
//  PPNetworkUtils.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 10/2/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPNetworkUtils : NSObject

+ (NSString *)percentEscapedStringKeyFromString:(NSString*)string
                                   withEncoding:(NSStringEncoding)encoding;

@end
