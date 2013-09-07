//
//  PPSignUpViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPSignUpViewController.h"
#import "UIViewController+Modal.h"
#import "NSString+Formatting.h"

#ifdef IS_IOS7_SDK
@interface PPSignUpViewController () <UIBarPositioningDelegate, UITextFieldDelegate>
#else
@interface PPSignUpViewController () <UITextFieldDelegate>
#endif

- (void)checkUserId;

- (void)validateUserId:(NSString*)userId
               success:(void (^)(void))success
               failure:(void (^)(void))failure;

@end

@implementation PPSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup uitextfield height
    CGRect userIdBounds = [self userIdTextField].bounds;
    userIdBounds.size.height = 36.f;
    [[self userIdTextField] setBounds:userIdBounds];
    
#ifdef IS_IOS7_SDK
    if (IS_IOS7_DEVICE) {
        [self navigationBar].delegate = self;
    } else {
        CGRect ios6NavBarFrame = [self navigationBar].frame;
        ios6NavBarFrame.origin.y = ios6NavBarFrame.origin.y - 20;
        [self navigationBar].frame = ios6NavBarFrame;
        
        CGRect ios6DescLabelFrame = [self userIdDescriptionLabel].frame;
        ios6DescLabelFrame.origin.y = ios6DescLabelFrame.origin.y - 10;
        [self userIdDescriptionLabel].frame = ios6DescLabelFrame;
    }
#endif
    
    self.userIdTextField.delegate = self;
    
    self.titleItem.title = _(@"PhotoPaySignUpTitle");
    self.doneButton.title = _(@"PhotoPaySignUpButtonDone");
    self.userIdDescriptionLabel.text = _(@"PhotoPaySignUpDescriptionLabel");
    
    self.statusLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[self userIdTextField] becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    [self checkUserId];
}

+ (NSString*)defaultXibName {
    if (IS_IPAD) {
        return @"PPSignUpViewController_iPad";
    } else {
        return @"PPSignUpViewController_iPhone";
    }
}

- (void)viewDidUnload {
    [self setUserIdTextField:nil];
    [self setUserIdDescriptionLabel:nil];
    [self setDoneButton:nil];
    [self setStatusLabel:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

- (void)checkUserId {
    [self validateUserId:[self userIdTextField].text
                 success:^(){
                     [[self statusLabel] setHidden:YES];
                     [[PPApp sharedApp] setUserId:[self userIdTextField].text];
                     [self dismissModalViewControllerAnimated:YES completion:nil];
                 }
                 failure:^(){
                     [[self statusLabel] setHidden:NO];
                 }];
}
        
- (void)validateUserId:(NSString*)userId
               success:(void (^)(void))success
        failure:(void (^)(void))failure {
    
    if (userId != nil && [userId isValidEmail]) {
        success();
    } else {
        [self statusLabel].text = _(@"PhotoPaySignUpErrorInvalid");
        failure();
    }
}

#ifdef IS_IOS7_SDK

#pragma mark - UIBarPositioning
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#endif

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdTextField) {
        [self checkUserId];
    }
    return YES;
}

@end
