//
//  PPApp.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PPApp : NSObject

/**
 Obtaines shared app instance
 */
+ (PPApp*)sharedApp;

/**
 User ID propertu which is used throughout the application to identify the user
 */
@property (getter = userId, setter = setUserId:) NSString* userId;

/**
 Obtains User ID from some kind of persistent storage
 */
- (NSString*)userId;

/**
 Saves User ID to persistent storage
 */
- (void)setUserId:(NSString*)userId;

@end
