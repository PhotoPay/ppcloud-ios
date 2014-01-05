//
//  PPLocalImageDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalImageDocument.h"
#import "UIImage+Processing.h"

static NSUInteger finalResolution = 2000000U; // 2 Mpix

@interface PPLocalImageDocument ()

@property (nonatomic, strong) UIImage* image;

@end

@implementation PPLocalImageDocument

@synthesize image;

- (id)initWithImage:(UIImage*)inImage
     processingType:(PPDocumentProcessingType)inProcessingType {
    
    // processing type must correspond with JPG image format of this document
    switch (inProcessingType) {
        case PPDocumentProcessingTypeAustrianPDFInvoice:
        case PPDocumentProcessingTypeSerbianPDFInvoice:
            [NSException raise:@"Invalid processing type"
                        format:@"Invalid processing type %@ for document type JPG", [PPDocument objectForDocumentProcessingType:inProcessingType]];
            break;
        default:
            break;
    }
    
    self = [super initWithBytes:nil
                   documentType:PPDocumentTypeJPG
                 processingType:inProcessingType];
    
    if (self) {
        image = inImage;
        previewImage_ = inImage;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PPLocalImageDocument *another = [super copyWithZone:zone];
    another->image = self->image;
    return another;
}

/**
 Bytes array can be generated from the imate, if it exists
 Othewise, it's loaded as any stored local document - from a file in documents folders
 */
- (NSData*)bytes {
    if (self->bytes_ == nil && image != nil) {
        // if we don't have bytes property, but have local UIImage, create bytes from UIImage
        self->bytes_ = [UIImage pp_jpegDataWithImage:[self image]
                                  scaledToResolution:finalResolution
                                    compressionLevel:0.8];
    } else if (self->bytes_ == nil) {
        // otherwise, create bytes like any other local document
        return [super bytes];
    }
    return self->bytes_;
}

- (UIImage*)image {
    if (image != nil) {
        return image;
    }
    image = [UIImage imageWithData:[self bytes]];
    return image;
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
            UIImage* fullImage = [self image];
            
            if (fullImage == nil) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    if (failure) {
                        failure();
                    }
                });
            }
            CGFloat width = 184.0f;
            CGSize thumbnailSize = CGSizeMake(width, width * fullImage.size.height / fullImage.size.width);
            thumbnailImage_ = [UIImage pp_imageWithImage:fullImage scaledToSize:thumbnailSize];
            
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
            UIImage* fullImage = [self image];
            previewImage_ = fullImage;
            
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
