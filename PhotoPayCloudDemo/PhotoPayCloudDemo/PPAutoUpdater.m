//
//  PPAutoUpdater.m
//  PhotoPay
//
//  Created by Jurica Cerovec on 3/15/13.
//  Copyright (c) 2013 Racuni.hr. All rights reserved.
//

#import "PPAutoUpdater.h"

@interface PPAutoUpdater () <UIAlertViewDelegate>

@property (nonatomic, retain) NSString* distributionUrl;
@property (nonatomic, retain) NSString* appName;

- (BOOL)isUpdateAvailable;
- (void)checkUpdate;
- (void)setupNotifications;
- (void)didEnterBackground:(NSNotification *)notification;
- (void)willEnterForeground:(NSNotification *)notification;

@end

@implementation PPAutoUpdater

+ (PPAutoUpdater*)sharedInstance {
    static PPAutoUpdater *sharedInstance = nil;
    
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[PPAutoUpdater alloc] init];
        }
        
        return sharedInstance;
    }
}

- (void)scanUpdatesForAppName:(NSString*)appName
              distributionUrl:(NSString*)distributionUrl {
    [self setAppName:appName];
    [self setDistributionUrl:distributionUrl];
    [self setupNotifications];
    [self checkUpdate];
}

- (void)setupNotifications {
    // watch for did enter background event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // watch for will enter foreground event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didEnterBackground:(NSNotification *)notification {
    
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self checkUpdate];
}

- (BOOL)isUpdateAvailable {
    BOOL updateAvailable = NO;
    NSString *updatePlistDictionary = [NSString stringWithFormat:@"%@/%@.plist", [self distributionUrl], [self appName]];
    NSDictionary *updateDictionary = [NSDictionary dictionaryWithContentsOfURL:
                                      [NSURL URLWithString:updatePlistDictionary]];
    
    if (updateDictionary) {
        NSArray *items = [updateDictionary objectForKey:@"items"];
        NSDictionary *itemDict = [items lastObject];
        
        NSDictionary *metaData = [itemDict objectForKey:@"metadata"];
        NSString *newversion = [metaData valueForKey:@"bundle-version"];
        NSString *currentversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        updateAvailable = [newversion compare:currentversion options:NSNumericSearch] == NSOrderedDescending;
        
    }
    
    return updateAvailable;
}

- (void)checkUpdate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([self isUpdateAvailable]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"A new version of %@ is available. Would you like to install it?", [self appName]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update available" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alert show];
            });
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        NSString *updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@%@.plist", [self distributionUrl], [self appName]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
    }
}

@end
