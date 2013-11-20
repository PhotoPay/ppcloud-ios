//
//  PPAppDelegate.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPAppDelegate.h"
#import "PPHomeViewController.h"
#import "PPAFNetworkManager.h"
#import <PhotoPayCloud/PhotoPayCloud.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "PPAlertView.h"
#import "PPAutoUpdater.h"
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDLog.h>

static NSString* appName = @"PhotoPayCloudDemo";
static NSString* distributionUrl = @"http://demo.photopay.net/distribute/iphone/srb-erste-cloud/";

@interface PPAppDelegate ()

@property (nonatomic, strong) UINavigationController* rootNavigationViewController;

- (void)configureApp;
- (void)configureLogger;
- (void)checkPhotoPayCloudUploads;

- (void)photoPayCloudLogin;
- (void)photoPayCloudLogout;

+ (AFHTTPRequestOperationManager*)requestOperationManager;

@end

@implementation PPAppDelegate

@synthesize rootNavigationViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // These should be called before crearing view controllers, so that they have
    // correct values set in their lifecycle methods
    [self configureApp];
    [self photoPayCloudLogin];
    
    PPHomeViewController *homeViewController = [[PPHomeViewController alloc] initWithNibName:[PPHomeViewController defaultXibName]
                                                                                  bundle:nil];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    
    rootNavigationViewController = navigationController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    if (IS_IOS7_DEVICE) {
#ifdef IS_IOS7_SDK
        navigationController.navigationBar.tintColor = [UIColor colorWithRed:190.0f/255.0f
                                                                       green:30.0f/255.0f
                                                                        blue:45.0f/255.0f
                                                                       alpha:1.0];
#endif
    }
    
    NSURL* url =  (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if ([url isFileURL] && [[[url pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        NSString *sourceApplication = (NSString *)[launchOptions valueForKey:UIApplicationLaunchOptionsSourceApplicationKey];
        [self application:application openURL:url sourceApplication:sourceApplication annotation:nil];
    }
    
    // This is where registration for push notifications will be done.
    // For now, this is only a demonstration, push notifications still don't work in demo app
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [[PPAutoUpdater sharedInstance] scanUpdatesForAppName:appName distributionUrl:distributionUrl];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (url) {
        if (!loggedIn) {
            [self photoPayCloudLogin];
        }
        PPLocalDocument *localDocument = [[PPLocalPdfDocument alloc] initWithLocalUrl:url processingType:PPDocumentProcessingTypeSerbianPDFInvoice];
        
        // send document to processing server
        [[PPPhotoPayCloudService sharedService] uploadDocument:localDocument
                                                      delegate:nil
                                                       success:nil
                                                       failure:nil
                                                      canceled:nil];
        
        [rootNavigationViewController popToRootViewControllerAnimated:NO];
    }
    return YES;
}

- (void)configureApp {
    [self configureLogger];
    [[PPApp sharedApp] setLanguage:@"hr"];
}

- (void)configureLogger {
    // we're using cocoa lumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DDLogInfo(@"Registered for push notify");
    [[PPPhotoPayCloudService sharedService] setDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Failed to register for push notify. Using dummy token!");
    [[PPPhotoPayCloudService sharedService] setDeviceToken:[@"dummyToken" dataUsingEncoding:NSUTF8StringEncoding]];
}

/** Hack to test logging out */
static bool loggedIn = false;

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)photoPayCloudLogout {
    if (!loggedIn) {
        [[PPPhotoPayCloudService sharedService] uninitialize];
    }
}

- (void)photoPayCloudLogin {
    loggedIn = true;

    PPAFNetworkManager* networkManager = [[PPAFNetworkManager alloc] initWithRequestOperationManager:[PPAppDelegate requestOperationManager]];
    [networkManager setMaxConcurrentUploadsCount:1];
    
    PPUser* user = [[PPUser alloc] initWithUserId:[[PPApp sharedApp] userId]
                                   organizationId:@"EBS"];
    
    [[PPPhotoPayCloudService sharedService] initializeForUser:user withNetworkManager:networkManager];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    static NSTimeInterval logoutInterval = 8.0f;
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    loggedIn = false;
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, logoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self photoPayCloudLogout];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // call configure photopaycloud because it's possible
    // that PhotoPayCloudService was deallocated in the meantime
    [self photoPayCloudLogin];
    
    [[PPAutoUpdater sharedInstance] scanUpdatesForAppName:appName distributionUrl:distributionUrl];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self checkPhotoPayCloudUploads];
}

+ (AFHTTPRequestOperationManager*)requestOperationManager {
    static AFHTTPRequestOperationManager* manager = nil;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
#ifdef DEBUG
        manager = [PPAFNetworkManager defaultOperationManagerForBaseURLString:@"http://cloudbeta.photopay.net/"];
#else
        manager = [PPAFNetworkManager defaultOperationManagerForBaseURLString:@"https://smartphonembankinguat.erstebank.rs:1027/"];
#endif
    });
    
    return manager;
}

- (void)checkPhotoPayCloudUploads {
    // check if PhotoPayCloudService was paused
    if ([[PPPhotoPayCloudService sharedService] state] == PPPhotoPayCloudServiceStatePaused) {
        // if true, ask user to continue or abort paused requests
        PPAlertView* alertView = [[PPAlertView alloc] initWithTitle:_(@"PhotoPayPendingUploadsAlertViewTitle")
                                                            message:_(@"PhotoPayPendingUploadsAlertViewMessage")
                                                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                             NSError* __autoreleasing error = nil;
                                                             if (buttonIndex == 0) {
                                                                 [[PPPhotoPayCloudService sharedService] deletePendingDocumentsWithError:&error];
                                                             } else if (buttonIndex == 1) {
                                                                 [[PPPhotoPayCloudService sharedService] uploadPendingDocuments];
                                                             }
                                                         }
                                                  cancelButtonTitle:_(@"PhotoPayPendingUploadsAlertViewAbort")
                                                  otherButtonTitles:_(@"PhotoPayPendingUploadsAlertViewContinue"), nil];
        [alertView show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
