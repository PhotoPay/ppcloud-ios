//
//  PPApp.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPApp.h"

@implementation PPApp

NSString* const keyUserId = @"helpShownKey";

+ (PPApp*)sharedApp {
    static PPApp* sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    NSLog(@"");
    
    return sharedInstance;
}

- (NSString*)userId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [defaults stringForKey:keyUserId];
    return userId;
}

- (void)setUserId:(NSString*)userId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* oldUserId = [defaults stringForKey:keyUserId];
    if (oldUserId != nil) {
        
    }
    
    [defaults setObject:userId forKey:keyUserId];
    [defaults synchronize];
}

@end
