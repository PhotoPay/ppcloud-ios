//
//  BaseCameraViewController.m
//  PhotoPayFramework
//
//  Created by Jurica Cerovec on 6/10/13.
//  Copyright (c) 2013 Racuni.hr. All rights reserved.
//

#import "PPBaseCameraViewController.h"
#import "PPCameraManager.h"

@interface PPBaseCameraViewController ()

@end

@implementation PPBaseCameraViewController

@synthesize cameraManager;
@synthesize inForeground;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        PPCameraManager *cManager = [[PPCameraManager alloc] init];
        [cManager setupSession];
        [self setCameraManager:cManager];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if ([self cameraManager] != nil) {
        CGRect rect = [[self view] frame];
        CGRect previewBounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
        
        CALayer *viewLayer = [[self view] layer];
        [viewLayer setMasksToBounds:YES];
        
        // setting the video preview layer
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[self cameraManager] videoPreviewLayer];
        [newCaptureVideoPreviewLayer setFrame:previewBounds];
        
        [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
    
    [self setInForeground:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupNotifications];
    [self setInForeground:YES];
    
    [self resumeCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setInForeground:NO];
    [self pauseCamera];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark View controller state tracking

- (void) setupNotifications {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraLoaded:)
                                                 name:AVCaptureSessionDidStartRunningNotification
                                               object:nil];
}

- (void)didEnterBackground:(NSNotification *)notification {
    [self pauseCamera];
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self.view setAlpha:0.0f];
    
    [self resumeCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setAlpha:0.0f];
    
    [super viewWillAppear:animated];
}

- (void)orientationChanged:(NSNotification *)notification {
    // nothing here, override if needed
}

- (void)cameraLoaded:(NSNotification *)notification {
    [UIView transitionWithView:[self view]
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn //any animation
                    animations:^ {
                        // when adding done, fade in the new HUD
                        [[self view] setAlpha:1.0];
                    }
                    completion:nil];
}

/** Camera pausing, when view dissapears or goes to background */
- (void)pauseCamera {
    [cameraManager stop];
}

/** Camera resuming, when view appears or comes from foreground */
- (void)resumeCamera {
    [cameraManager start];
}

#pragma mark - autorotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)captureImageWithCompletionHandler:(void (^)(UIImage* image, NSError *error))handler
{
    [self.cameraManager captureImageWithCompletionHandler:handler];
}

@end
