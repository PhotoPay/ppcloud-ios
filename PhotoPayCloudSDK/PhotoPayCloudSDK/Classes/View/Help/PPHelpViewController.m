//
//  PhotopayHelpViewController.m
//  iphone-photopay
//
//  Created by Ja on 11/10/11.
//  Copyright (c) 2011 jcerovec@gmail.com. All rights reserved.
//

#import "PPHelpViewController.h"

@implementation PPHelpViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _helpImageLabel.adjustsFontSizeToFitWidth = YES;
    _helpImageLabel.font = [UIFont systemFontOfSize:18.0f];
}

- (void)viewDidUnload {
    [self setHelpImageView:nil];
    [self setHelpImageLabel:nil];
    [super viewDidUnload];
}

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

@end
