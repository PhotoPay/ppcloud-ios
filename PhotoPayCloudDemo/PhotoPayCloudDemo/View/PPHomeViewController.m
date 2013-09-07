//
//  PPHomeViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeViewController.h"
#import "PPSignUpViewController.h"
#import "UIViewController+Modal.h"

@interface PPHomeViewController ()

- (BOOL)isSignUpRequested;

@end

@implementation PPHomeViewController

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
    
    [self setTitle:_(@"PhotoPayHomeTitle")];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self isSignUpRequested]) {
        return;
    }
}

- (BOOL)isSignUpRequested {
    if ([[PPApp sharedApp] userId] == nil) {
        PPSignUpViewController* signUpViewController = [[PPSignUpViewController alloc] initWithNibName:[PPSignUpViewController defaultXibName]
                                                                                                bundle:nil];
        [self presentModalViewController:signUpViewController animated:NO completion:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
