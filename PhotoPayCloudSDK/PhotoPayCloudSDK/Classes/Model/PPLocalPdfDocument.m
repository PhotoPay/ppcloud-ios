//
//  PPLocalPdfDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 27/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalPdfDocument.h"
#import "UIImage+PDF.h"

@implementation PPLocalPdfDocument

- (id)initWithLocalUrl:(NSURL*)localUrl
        processingType:(PPDocumentProcessingType)inProcessingType {
    
    // processing type must correspond with JPG image format of this document
    switch (inProcessingType) {
        case PPDocumentProcessingTypeAustrianPhotoInvoice:
        case PPDocumentProcessingTypeBosnianPhotoInvoice:
        case PPDocumentProcessingTypeSerbianPhotoInvoice:
            [NSException raise:@"Invalid processing type"
                        format:@"Invalid processing type %@ for document type PDF", [PPDocument objectForDocumentProcessingType:inProcessingType]];
            break;
        default:
            break;
    }
    
    self = [super initWithURL:localUrl
                 documentType:PPDocumentTypePDF
               processingType:inProcessingType];
    
    return self;
}


- (void)thumbnailImageWithSuccess:(void (^)(UIImage *))success
                          failure:(void (^)(void))failure {
    if (thumbnailImage_ != nil) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                success(thumbnailImage_);
            });
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            thumbnailImage_ = [UIImage imageFromPdfWithUrl:[self cachedDocumentUrl] size:CGSizeMake(144, 192)];
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (thumbnailImage_ != nil) {
                    if (success) {
                        success(thumbnailImage_);
                    };
                } else {
                    if (failure) {
                        failure();
                    }
                }
            });
        });
    }
}

- (void)previewImageWithSuccess:(void (^)(UIImage* previewImage))success
                        failure:(void (^)(void))failure {
    if (previewImage_ != nil) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                success(previewImage_);
            });
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            previewImage_ = [UIImage imageFromPdfWithUrl:[self cachedDocumentUrl] size:CGSizeMake(336, 450)];
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (previewImage_ != nil) {
                    if (success) {
                        success(previewImage_);
                    };
                } else {
                    if (failure) {
                        failure();
                    }
                }
            });
        });
    }
}


@end
