//
//  PPApp.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPApp.h"

NSString* const keyUserId = @"keyUserID";
NSString* const keyLanguage = @"keyLanguage";

@interface PPApp ()

@property (nonatomic, retain) NSSet* supportedLanguages;

@property (nonatomic, retain) NSMutableArray* statusBarStack;

@end

@implementation PPApp

@synthesize language;
@synthesize supportedLanguages;
@synthesize statusBarStack;

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
        statusBarStack = [[NSMutableArray alloc] init];
        supportedLanguages = [[NSSet alloc] initWithObjects:@"en", @"hr", nil];
        [self setDefaultLanguage];
    }
    return self;
}

- (NSString*)userId {
    [self setUserId:@"dev@null"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userId = [defaults stringForKey:keyUserId];
    if (userId == nil || [userId length] == 0) {
        DDLogInfo(@"User ID doesn't exist, please provide one");
        return nil;
    }
    
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
    if (inLanguage == nil || [inLanguage length] == 0) {
        DDLogError(@"Invalid language %@, previously specified language will be used", inLanguage);
        return;
    }

    if ([[self supportedLanguages] containsObject:inLanguage]) {
        language = inLanguage; // replace cached value
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:inLanguage forKey:keyLanguage];
        [defaults synchronize];
    }
}

- (void)setDefaultLanguage {
    // if not return value from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* storedLanguage = [defaults stringForKey:keyLanguage];
    
    if (storedLanguage != nil) {
        language = storedLanguage;
        return;
    }
    
    NSString *defaultLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (![supportedLanguages containsObject:defaultLanguage]) {
        defaultLanguage = @"en"; // if phone's default language is not supported, use english localization
    }
    
    [defaults setObject:defaultLanguage forKey:keyLanguage];
    [defaults synchronize];
    
    language = defaultLanguage;
}

- (void)pushStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [statusBarStack addObject:[NSNumber numberWithBool:[[UIApplication sharedApplication] statusBarStyle]]];
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
}

- (void)popStatusBarStyle {
    UIStatusBarStyle style = [[statusBarStack lastObject] intValue];
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:YES];
    [statusBarStack removeLastObject];
}

@end
