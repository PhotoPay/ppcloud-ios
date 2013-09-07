//
//  BaseCameraViewController.h
//  PhotoPayFramework
//
//  Created by Jurica Cerovec on 6/10/13.
//  Copyright (c) 2013 Racuni.hr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPCameraManager;

@interface PPBaseCameraViewController : UIViewController

/** Object responsible for camera starting, stopping and managing settings */
@property (nonatomic, strong) PPCameraManager* cameraManager;

/** True if camera is in foreground and scanning is in progress */
@property (nonatomic, assign, getter = isInForeground) BOOL inForeground;

/** Camera pausing, when view dissapears or goes to background */
- (void)pauseCamera;

/** Camera resuming, when view appears or comes from foreground */
- (void)resumeCamera;

/** Controlling view controller's state */
- (void)setupNotifications;

/** Called with notification when camera view controller enters background */
- (void)didEnterBackground:(NSNotification *)notification;

/** Called with notification when camera view controller enters foreground */
- (void)willEnterForeground:(NSNotification *)notification;

/** Called with notification when camera view controller changes orientation */
- (void)orientationChanged:(NSNotification *)notification;

/** Called with notification when camera session starts running */
- (void)cameraLoaded:(NSNotification *)notification;

/** Take still image from camera */
- (void)captureImageWithCompletionHandler:(void (^)(UIImage* image, NSError *error))handler;

@end
