//
//  PPApp.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Accessing localization files
#ifndef _
#define _(s) NSLocalizedStringFromTable(s,[PPApp sharedApp].language,s)
#endif

#ifndef __
#define __(s,...) [NSString stringWithFormat:NSLocalizedStringFromTable(s,[PPApp sharedApp].language,s),##__VA_ARGS__]
#endif


@interface PPApp : NSObject

/**
 Obtaines shared app instance
 */
+ (PPApp*)sharedApp;

/**
 Language used in the App
 */
@property (nonatomic, strong, setter=setLanguage:) NSString* language;

/**
 User ID propertu which is used throughout the application to identify the user
 */
@property (getter = userId, setter = setUserId:) NSString* userId;

/**
 Initializes the App object
 */
- (id)init;

/**
 Obtains User ID from some kind of persistent storage
 */
- (NSString*)userId;

/**
 Saves User ID to persistent storage
 */
- (void)setUserId:(NSString*)userId;

/**
 Sets the language for the App
 */
- (void)setLanguage:(NSString *)inLanguage;

/**
 Sets the system language (specified by the user in iOS Settings) to be the language of the App
 */
- (void)setDefaultLanguage;

/**
 Sets the status bar style to specified value. Also saves the last value on internal stack
 so it can be easily restored later
 */
- (void)pushStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

/**
 Restores the last value of status bar style
 */
- (void)popStatusBarStyle;

@end
