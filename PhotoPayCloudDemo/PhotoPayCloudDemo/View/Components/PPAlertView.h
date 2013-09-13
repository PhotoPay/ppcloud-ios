//
//  PPAlertView.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Simple wrapper around UIAlertView to enable callbacks with blocks */
@interface PPAlertView : UIAlertView <UIAlertViewDelegate>

/** Initializes with completion block instead of the delegate */
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
         completion:(void (^)(BOOL cancelled, NSInteger buttonIndex))completion
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
