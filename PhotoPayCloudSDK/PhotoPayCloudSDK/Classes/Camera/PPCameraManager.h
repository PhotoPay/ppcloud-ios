//
//  PPCameraManager.h
//  PhotoPaySdk
//
//  Created by Jurica Cerovec on 11/18/11.
//  Copyright (c) 2011 Racuni.hr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 * Encapsulates camera related activities
 */
@interface PPCameraManager : NSObject

/** Video input object */
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

/** Still image output object */
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

/** Output which generates video frames */
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

/** Video preview which is shown on the screen */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

/** Session preset property */
@property (nonatomic, weak) NSString *const sessionPreset;

/** Video gravity */
@property (nonatomic, weak) NSString *const videoGravity;

/** Marks if the camera is focused */
@property (nonatomic, assign, getter = isCameraFocused) BOOL cameraFocused;

/** Focus point for manual AF */
@property (nonatomic, assign) CGPoint focusPoint;

/** Initializes the camera session */
- (BOOL)setupSession;

/** Starts the camera session, flash, torch and frame saving process. Also makes the camera do the autofocus */
- (BOOL)start;

/** Pauses the frame saving process and stops the camera session */
- (BOOL)stop;

/** requests autofocus */
- (void)requestFocus;

/** request focus at specific point */
- (void)requestFocusAtPoint:(CGPoint)focusPoint;

/** Sets the torch mode and returns true if available */
- (BOOL)setTorch:(AVCaptureTorchMode)mode;

/** Returns true if camera supports torch mode */
- (BOOL)isTorchSupported;

/** Returns true if torch mode is on */
- (BOOL)isTorchOn;

/** Class function which retrieves connection to some media type */
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

/** Capture image from camera connection */
- (void)captureImageWithCompletionHandler:(void (^)(UIImage* image, NSError *error))handler;

@end
