//
//  UIViewController+ContainerViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jura on 08/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ContainerViewController)

- (CGRect)pp_frameForChildViewController;

- (void)pp_displayContentController:(UIViewController*)content;

- (void)pp_hideContentController: (UIViewController*)content;

@end
