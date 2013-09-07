//
//  PPCameraManager.m
//  PhotoPaySdk
//
//  Created by Jurica Cerovec on 11/18/11.
//  Copyright (c) 2011 Racuni.hr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPCameraManager.h"

static const int autofocusIntervalMills = 3200;

@interface PPCameraManager () 

/** Capture session */
@property (nonatomic, strong) AVCaptureSession *session;

/** Property which indicates that the camera manager is working */
@property (nonatomic, assign, getter = isStarted) BOOL started;

/** Property which indicates that the camera manager is working */
@property (nonatomic, assign, getter = isFocusingInProgress) BOOL focusingInProgress;

/** Timer which performs manual continuous autofocus */
@property (nonatomic, strong) NSTimer* autofocusTimer;

/** Sets the focus mode to continuous */
- (void)requestContinuousAutofocus;

/** Sets the autofocus mode and returns true if available */
- (BOOL)setAutofocus:(AVCaptureFocusMode) mode;

/** Sets the flash mode and returns true if available */
- (BOOL)setFlash:(AVCaptureFlashMode) mode;

/** Sets the white balance mode and returns true if available */
- (BOOL)setWhiteBalance:(AVCaptureWhiteBalanceMode)mode;

/** Method starts the notification cycle for autofocus property */
- (void)observeAutofocus;

/** Method cancels the notification cycle for autofocus property */
- (void)stopObservingAutofocus;

/** Callback for autofocusing started notfication */
- (void)autofocusingStarted;

/** Callback for autofocusing ended notfication */
- (void)autofocusingFinished;

/** Sets the camera focused property */
- (void)setFocused;

/** Returns a reference to the camera with certain position */
+ (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position;

/** returns a reference to the front facing camera */
+ (AVCaptureDevice *)frontFacingCamera;

/** returns a reference to the back facing camera */
+ (AVCaptureDevice *)backFacingCamera;

@end

@implementation PPCameraManager

@synthesize session;
@synthesize videoInput;
@synthesize videoDataOutput;
@synthesize videoPreviewLayer;
@synthesize cameraFocused;
@synthesize focusingInProgress;
@synthesize started;
@synthesize stillImageOutput;
@synthesize sessionPreset;
@synthesize autofocusTimer;
@synthesize videoGravity;

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        started = NO;
        [self setSessionPreset:AVCaptureSessionPresetPhoto];
        [self setFocusPoint:CGPointMake(0.5f, 0.5f)];
        [self setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return self;
}

- (BOOL)setupSession {
    BOOL success = NO;
    
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[PPCameraManager backFacingCamera] error:nil];
    if (newVideoInput == nil) {
        NSLog(@"Capture device input fail!");
    }
	
    // setup video data output
    AVCaptureVideoDataOutput *newVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (newVideoDataOutput == nil) {
        NSLog(@"Video data output fail!");
    }
    newVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    [newVideoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if (newStillImageOutput == nil) {
        NSLog(@"Still image output fail!");
    }
    
    [newStillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];

    // Create session (use default AVCaptureSessionPresetHigh)
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    if (newCaptureSession == nil) {
        NSLog(@"Capture session fail!");
    }
    
    // setup session preset
    newCaptureSession.sessionPreset = [self sessionPreset];
    
    [self setVideoInput:newVideoInput];
    [self setVideoDataOutput:newVideoDataOutput];
    [self setStillImageOutput:newStillImageOutput];
    [self setSession:newCaptureSession];
    
    
    success = YES;
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self session]];
    if (newCaptureVideoPreviewLayer == nil) {
        NSLog(@"Capture video preview layer fail!");
    }
    
    [newCaptureVideoPreviewLayer setVideoGravity:[self videoGravity]];
    [self setVideoPreviewLayer:newCaptureVideoPreviewLayer];
    
    return success;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (BOOL)start {
    BOOL success = YES;
    
    if (![self isStarted]) {
        // Add inputs and output to the capture session
        if ([[self session] canAddInput:[self videoInput]]) {
            [[self session] addInput:[self videoInput]];
        }
        if ([[self session] canAddOutput:[self videoDataOutput]]) {
            [[self session] addOutput:[self videoDataOutput]];
        }
        if ([[self session] canAddOutput:[self stillImageOutput]]) {
            [[self session] addOutput:[self stillImageOutput]];
        }
        
        AVCaptureConnection *videoOutputConnection =
            [PPCameraManager connectionWithMediaType:AVMediaTypeVideo
                                 fromConnections:[[self videoDataOutput] connections]];
        
        if (videoOutputConnection != nil) {
            if ([videoOutputConnection respondsToSelector:@selector(isVideoOrientationSupported)] &&
                [videoOutputConnection respondsToSelector:@selector(setVideoOrientation:)] &&
                [videoOutputConnection isVideoOrientationSupported]) {
                [videoOutputConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            } else {
                if ([[self videoPreviewLayer] respondsToSelector:@selector(isOrientationSupported)] &&
                    [[self videoPreviewLayer] respondsToSelector:@selector(setOrientation:)] &&
                    [[self videoPreviewLayer] isOrientationSupported]) {
                    [[self videoPreviewLayer] setOrientation:AVCaptureVideoOrientationPortrait];
                }
            }
            if ([videoOutputConnection respondsToSelector:@selector(isVideoMinFrameDurationSupported)] &&
                [videoOutputConnection respondsToSelector:@selector(setVideoMinFrameDuration:)] &&
                [videoOutputConnection isVideoMinFrameDurationSupported]) {
                [videoOutputConnection setVideoMinFrameDuration:CMTimeMake(1, 24)];
            } else {
                if ([[self videoDataOutput] respondsToSelector:@selector(setMinFrameDuration:)]) {
                    [[self videoDataOutput] setMinFrameDuration:CMTimeMake(1, 24)];
                }
            }
        } else {
            if ([[self videoPreviewLayer] respondsToSelector:@selector(isOrientationSupported)] &&
                [[self videoPreviewLayer] respondsToSelector:@selector(setOrientation:)] &&
                [[self videoPreviewLayer] isOrientationSupported]) {
                [[self videoPreviewLayer] setOrientation:AVCaptureVideoOrientationPortrait];
            };
            if ([[self videoDataOutput] respondsToSelector:@selector(setMinFrameDuration:)]) {
                [[self videoDataOutput] setMinFrameDuration:CMTimeMake(1, 24)];
            }
        }
        
        [self observeAutofocus]; // start observing autofocus
        
        // turn off flash and torch
        [self setFlash:AVCaptureFlashModeOff];
        [self setWhiteBalance:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        [[self session] startRunning];
        
        cameraFocused = NO; // camera is unfocused
        focusingInProgress = NO;
        [self setTorch:AVCaptureTorchModeOff];
        
        started = YES;
    }
    
    return success;
}

#pragma clang diagnostic pop

- (BOOL)stop {
    if ([self isStarted]) {
        // invalidate focus timer
        [[self autofocusTimer] invalidate];

        [[self videoDataOutput] setSampleBufferDelegate:nil queue:nil]; // stop receiving frames    
        cameraFocused = NO; // camera is no longer focused
        
        [[self session] stopRunning];
        
        [self stopObservingAutofocus]; // stop observing autofocus
        
        started = NO;
        
        [[self session] removeInput:[self videoInput]];
        [[self session] removeOutput:[self videoDataOutput]];
        [[self session] removeOutput:[self stillImageOutput]];
    }
    
    return YES;
}


#pragma mark -
#pragma mark Class methods

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
+ (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
+ (AVCaptureDevice *)frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
+ (AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
	for (AVCaptureConnection *connection in connections) {
		for (AVCaptureInputPort *port in [connection inputPorts] ) {
			if ([[port mediaType] isEqual:mediaType]) {
				return connection;
			}
		}
	}
	return nil;
}

#pragma mark -
#pragma mark camera settings functions

- (BOOL)setAutofocus:(AVCaptureFocusMode)mode {
    BOOL success = YES;
    if ([[PPCameraManager backFacingCamera] lockForConfiguration:nil]) {
        if ([[PPCameraManager backFacingCamera] isFocusModeSupported:mode]) {
            [[PPCameraManager backFacingCamera] setFocusMode:mode];
        } else {
            success = NO;
        }
        [[PPCameraManager backFacingCamera] unlockForConfiguration];
    }
    return success;
}

- (BOOL)setFlash:(AVCaptureFlashMode)mode {
    BOOL success = YES;
    if ([[PPCameraManager backFacingCamera] hasFlash]) {
		if ([[PPCameraManager backFacingCamera] lockForConfiguration:nil]) {
			if ([[PPCameraManager backFacingCamera] isFlashModeSupported:mode]) {
				[[PPCameraManager backFacingCamera] setFlashMode:mode];
			} else {
                success = NO;
            }
			[[PPCameraManager backFacingCamera] unlockForConfiguration];
		}
	}
    return success;
}

- (BOOL)isTorchOn {
    return ([[PPCameraManager backFacingCamera] torchMode] == AVCaptureTorchModeOn);
}

- (BOOL)isTorchSupported {
    return [[PPCameraManager backFacingCamera] isTorchModeSupported:AVCaptureTorchModeOn];
}

- (BOOL)setTorch:(AVCaptureTorchMode)mode {
    BOOL success = YES;
    if ([[PPCameraManager backFacingCamera] hasTorch]) {
		if ([[PPCameraManager backFacingCamera] lockForConfiguration:nil]) {
			if ([[PPCameraManager backFacingCamera] isTorchModeSupported:mode]) {
				[[PPCameraManager backFacingCamera] setTorchMode:mode];
			} else {
                success = NO;
            }
			[[PPCameraManager backFacingCamera] unlockForConfiguration];
		}
	}
    return success;
}

- (BOOL)setWhiteBalance:(AVCaptureWhiteBalanceMode)mode {
    BOOL success = YES;
    if ([[PPCameraManager backFacingCamera] lockForConfiguration:nil]) {
        if ([[PPCameraManager backFacingCamera] isWhiteBalanceModeSupported:mode]) {
            [[PPCameraManager backFacingCamera] setWhiteBalanceMode:mode];
        } else {
            success = NO;
        }
        [[PPCameraManager backFacingCamera] unlockForConfiguration];
    }
    return success;
}

#pragma mark -
#pragma mark Autofocus methods

- (void)observeAutofocus {
    [[PPCameraManager backFacingCamera] addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingAutofocus {
    [[PPCameraManager backFacingCamera] removeObserver:self forKeyPath:@"adjustingFocus"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (adjustingFocus) {
            [self autofocusingStarted];
        } else {
            [self autofocusingFinished];
        }
    }
}

- (void)autofocusingStarted {
    [self setFocusingInProgress:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(setFocused)
                                               object:nil];
    [self setCameraFocused:NO];
}

- (void)autofocusingFinished {
    [self setFocusingInProgress:NO];
    [self performSelector:@selector(setFocused) withObject:nil afterDelay:0.4];
}

- (void)setFocused {
    [self setCameraFocused:YES];
}

- (void)requestContinuousAutofocus {
    [self setAutofocus:AVCaptureFocusModeContinuousAutoFocus];
}

- (void)requestFocus {
    // invalidate focus timer
    [[self autofocusTimer] invalidate];
    
    // schedule focus in N seconds
    [self setAutofocusTimer:[NSTimer scheduledTimerWithTimeInterval:autofocusIntervalMills / 1000.f
                                                             target:self
                                                           selector:@selector(requestFocus)
                                                           userInfo:nil
                                                            repeats:NO]];
    
    if (![self isFocusingInProgress]) {
        [self autofocusingStarted];
        [self requestFocusAtPoint:[self focusPoint]];
    }
}

- (void)requestFocusAtPoint:(CGPoint)focusPoint {
    // Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:focusPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }       
    } else {
        [self setAutofocus:AVCaptureFocusModeAutoFocus];
    }
    
    [self setAutofocus:AVCaptureFocusModeContinuousAutoFocus]; // set autofocus continuous
}

- (void)captureImageWithCompletionHandler:(void (^)(UIImage* image, NSError *error))handler
{
    AVCaptureConnection *stillImageConnection =
    [PPCameraManager connectionWithMediaType:AVMediaTypeVideo
                             fromConnections:[[self stillImageOutput] connections]];
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:
        ^(CMSampleBufferRef imageBuffer, NSError *error) {
            handler([PPCameraManager imageFromSampleBuffer:imageBuffer], error);
        }
     ];
}

+ (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    UIImage* image = [UIImage imageWithCGImage:newImage];
    
    CFRelease(newImage);
    
    return image;
}

@end
