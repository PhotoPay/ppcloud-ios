//
//  PPApp.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPApp.h"

NSString* const keyUserId = @"keyUserID";

@interface PPApp ()

@property (nonatomic, retain) NSSet* supportedLanguages;

@end

@implementation PPApp

@synthesize language;
@synthesize supportedLanguages;

+ (PPApp*)sharedApp {
    static PPApp* sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        supportedLanguages = [[NSSet alloc] initWithObjects:@"en", @"hr", nil];
        [self setDefaultLanguage];
    }
    return self;
}

- (NSString*)userId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userId = [defaults stringForKey:keyUserId];
    if (userId == nil || [userId length] == 0) {
        DDLogInfo(@"User ID doesn't exist, please provide one");
        return nil;
    }
    
    return nil;
    return userId;
}

- (void)setUserId:(NSString*)userId {
    if (userId == nil || [userId length] == 0) {
        DDLogError(@"Invalid UserID %@", userId);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* oldUserId = [defaults stringForKey:keyUserId];
    if (oldUserId != nil) {
        DDLogWarn(@"Existing UserID %@ will be replaced with %@", oldUserId, userId);
    }
    
    [defaults setObject:userId forKey:keyUserId];
    [defaults synchronize];
}

- (void)setLanguage:(NSString *)inLanguage {
    if ([supportedLanguages containsObject:inLanguage]) {
        language = inLanguage;
    } else {
        DDLogWarn(@"Unsupported language %@, setting phone default language", inLanguage);
        [self setDefaultLanguage];
    }
}

- (void)setDefaultLanguage {
    NSString *defaultLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([supportedLanguages containsObject:defaultLanguage]) {
        [self setLanguage:defaultLanguage];
    } else {
        DDLogWarn(@"Phone default language unsupported, setting English");
        [self setLanguage:@"en"];
    }
}

@end
