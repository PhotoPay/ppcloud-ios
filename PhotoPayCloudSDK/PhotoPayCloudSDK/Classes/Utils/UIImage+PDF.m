//
//  UIImage+PDF.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 28/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "UIImage+PDF.h"

// iPad/iPhone shortcuts
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (!IS_IPAD)
#define IS_RETINA ([UIScreen mainScreen].scale == 2.0)

@implementation UIImage (PDF)

+ (UIImage*)imageFromPdfWithUrl:(NSURL*)url
                           size:(CGSize)imageSize {
    CFURLRef pdfURL = (__bridge CFURLRef)url;
    
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL);
    
    UIImage *image = [UIImage imageFromPDFWithDocumentRef:pdfRef
                                               pageNumber:1
                                                     size:imageSize];
    
    CGPDFDocumentRelease(pdfRef);
    
    return image;
}

+ (UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef
                              pageNumber:(int)pageNumber
                                    size:(CGSize)imageSize {
    
    if (CGPDFDocumentIsEncrypted(documentRef)) {
        // set the font type and size
        UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
        return [UIImage imageFromText:(@"Encrypted") font:font size:imageSize];
    }
    
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, pageNumber);
    size_t numPages = CGPDFDocumentGetNumberOfPages(documentRef);
    
    CGFloat scale = 1.0f;
    if (IS_RETINA) {
        scale = 2.0f;
    }
    CGRect pageRect = CGRectMake(0, 0, imageSize.width * scale, imageSize.height * scale);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, pageRect);
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect cropBox = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    CGRect targetRect = pageRect;
    NSLog(@"cropBox %f %f", cropBox.size.width, cropBox.size.height);
    CGFloat xScale = targetRect.size.width / cropBox.size.width;
    CGFloat yScale = targetRect.size.height / cropBox.size.height;
    CGFloat scaleToApply = xScale < yScale ? xScale : yScale;
    
    NSLog(@"Scale %f", scaleToApply);
    CGContextConcatCTM(context, CGAffineTransformMakeScale(scaleToApply, scaleToApply));
    
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}


+ (UIImage *)imageFromText:(NSString *)text
                      font:(UIFont*)font
                      size:(CGSize)imageSize {
                          
    CGFloat scale = 1.0f;
    if (IS_RETINA) {
        scale = 2.0f;
    }
    
    CGSize constrainedSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(imageSize.width * scale, imageSize.height * scale)];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(constrainedSize, NO, 0.0);
    } else {
        // iOS is < 4.0
        UIGraphicsBeginImageContext(constrainedSize);
    }
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context, you can use also drawInRect:withFont:
    [text drawInRect:CGRectMake(0, 0, constrainedSize.width, constrainedSize.height) withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
