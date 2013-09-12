//
//  UIImage+Processing.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "UIImage+Processing.h"

@implementation UIImage (Processing)

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSData*)jpegDataWithImage:(UIImage*)image
          scaledToResolution:(NSUInteger)mpixels
            compressionLevel:(CGFloat)compressionLevel {
    
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = sqrt((float) mpixels / oldHeight / oldWidth);
    
    CGFloat newWidth = round(scaleFactor * oldWidth);
    CGFloat newHeight = round(scaleFactor * oldHeight);
    
    NSLog(@"Image width %f, height %f", newWidth, newHeight);
    
    return UIImageJPEGRepresentation([UIImage imageWithImage:image scaledToSize:CGSizeMake(newWidth, newHeight)], compressionLevel);
}

@end
