//
//  NSString+Factory.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Factory)

+ (NSString *)pp_UUID;

- (NSString *)pp_MD5;

- (NSString *)pp_SHA1;

@end
