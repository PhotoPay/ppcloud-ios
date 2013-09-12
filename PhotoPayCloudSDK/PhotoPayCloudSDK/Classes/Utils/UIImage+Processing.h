//
//  UIImage+Processing.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Processing)

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;

+ (NSData*)jpegDataWithImage:(UIImage*)image
          scaledToResolution:(NSUInteger)mpixels
            compressionLevel:(CGFloat)compressionLevel;

@end
