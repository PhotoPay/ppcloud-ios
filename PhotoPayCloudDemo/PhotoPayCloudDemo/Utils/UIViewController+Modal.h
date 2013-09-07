//
//  UIViewController+Modal.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Modal)

/**
 Display another view controller as a modal child. Uses a vertical sheet transition if animated.
 */
- (void)presentModalViewController:(UIViewController*)viewController
                          animated:(BOOL)animated
                        completion:(void (^)(void))completion;

/**
 Dismiss the current modal child. Uses a vertical sheet transition if animated.
 */
- (void)dismissModalViewControllerAnimated:(BOOL)animated
                                completion:(void (^)(void))completion;

@end
