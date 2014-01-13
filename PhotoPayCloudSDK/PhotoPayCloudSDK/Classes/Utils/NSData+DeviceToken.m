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
//    return [NSString stringWithUTF8String:[self bytes]];
    const unsigned* tokenBytes = [self bytes];
    return [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
     ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
     ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
     ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
}

@end
