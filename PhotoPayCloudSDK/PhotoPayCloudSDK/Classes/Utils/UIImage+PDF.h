//
//  UIImage+PDF.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 28/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PDF)

+ (UIImage*)imageFromPdfWithUrl:(NSURL*)url
                           size:(CGSize)size;

+ (UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef
                              pageNumber:(int)pageNumber
                                    size:(CGSize)size;

+ (UIImage *)imageFromText:(NSString *)text
                      font:(UIFont*)font
                      size:(CGSize)size;

@end
