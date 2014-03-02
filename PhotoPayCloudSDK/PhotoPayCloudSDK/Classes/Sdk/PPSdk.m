//
//  PPSdk.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 01/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPSdk.h"

@implementation PPSdk

+ (PPSdk*)sharedSdk {
    static PPSdk* sharedSdk = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSdk = [[PPSdk alloc] init];
        sharedSdk.logger = [[PPLogger alloc] init];
        sharedSdk.localizer = [[PPLocalizer alloc] init];
    });
    
    return sharedSdk;
}

@end
