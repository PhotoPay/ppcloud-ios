//
//  PPAlertView.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPAlertView.h"

@interface PPAlertView ()

/** Block needs to be saved */
@property (copy, nonatomic) void (^completion)(BOOL, NSInteger);

@end

@implementation PPAlertView

@synthesize completion;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
         completion:(void (^)(BOOL cancelled, NSInteger buttonIndex))inCompletion
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    self = [self initWithTitle:title
                       message:message
                      delegate:self
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:nil ];
    
    if (self) {
        completion = inCompletion;
        
        va_list arguments;
        va_start(arguments, otherButtonTitles);
        
        for (NSString *key = otherButtonTitles; key != nil; key = (__bridge NSString *)va_arg(arguments, void *)) {
            [self addButtonWithTitle:key];
        }
        
        va_end(arguments);
    }
    return self;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.completion(buttonIndex == self.cancelButtonIndex, buttonIndex);
}

@end
