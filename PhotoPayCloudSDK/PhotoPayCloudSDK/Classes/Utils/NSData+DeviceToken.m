//
//  NSData+DeviceToken.m
//  PhotoPayCloudSDK
//
//  Created by DoDo on 20/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "NSData+DeviceToken.h"

@implementation NSData (DeviceToken)

// dummy implementation that just returns string built from NSData
- (NSString*)stringFromDeviceToken {
    return [NSString stringWithUTF8String:[self bytes]];
}

@end
