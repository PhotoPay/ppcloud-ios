//
//  NSString+Factory.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Factory)

+ (NSString *)UUID;

- (NSString *)MD5;

- (NSString *)SHA1;

@end
