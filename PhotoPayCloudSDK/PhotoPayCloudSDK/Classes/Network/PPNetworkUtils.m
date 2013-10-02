//
//  PPNetworkUtils.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 10/2/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPNetworkUtils.h"

static NSString * const kPPCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * const kPPCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";

@implementation PPNetworkUtils

+ (NSString *)percentEscapedStringKeyFromString:(NSString*)string
                                   withEncoding:(NSStringEncoding)encoding {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kPPCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kPPCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end
