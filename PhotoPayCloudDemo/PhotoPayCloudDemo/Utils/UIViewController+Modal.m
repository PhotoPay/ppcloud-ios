//
//  UIViewController+Modal.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "UIViewController+Modal.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation UIViewController (Modal)

- (void)presentModalViewController:(UIViewController*)viewController
                           animated:(BOOL)animated
                         completion:(void (^)(void))completion {
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:viewController animated:animated completion:completion];
    } else {
        [self presentModalViewController:viewController animated:animated];
    }
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
                                completion:(void (^)(void))completion {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:animated completion:completion];
    } else {
        [self dismissModalViewControllerAnimated:animated];
    }
}

@end

#pragma clang diagnostic pop
