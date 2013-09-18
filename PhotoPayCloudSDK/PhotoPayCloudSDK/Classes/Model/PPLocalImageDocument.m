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

@property (nonatomic, strong) UIImage* thumbnailImage;

@end

@implementation PPLocalImageDocument

@synthesize image;
@synthesize thumbnailImage;

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
        thumbnailImage = nil;
    }
    
    return self;
}

/** 
 There are three states in which a local image document can be found.
 From all of these states properties URL and BYTES must be reachable.
 
 To ensure this, this custom getter is provided. We handle these cases:
 
 1. BYTES and URL properties are nil.
        IMAGE property is decoded and downsampled so that the BYTES property can be set
 2. BYTES is still nil
        Superclass implementation is called. @see [PPLocalDocument bytes]
 3. BYTES is available
        simply returned that value
 */
- (NSData*)bytes {
    if (self->bytes_ == nil && self.url == nil) {
        if ([self image] == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Local document should have either URL, BYTES or IMAGE property set. Save the document using saveUsingDocumentManager:success:failure and use the bytes property in callbacks only"
                                         userInfo:nil];
        }
        // we need to have UIImage object here
        self->bytes_ = [UIImage jpegDataWithImage:[image fixOrientation]
                               scaledToResolution:finalResolution
                                 compressionLevel:0.9];
    }
    if (self->bytes_ == nil) {
        return [super bytes];
    }
    return self->bytes_;
}

- (UIImage*)image {
    if (image == nil) {
        image = [UIImage imageWithData:[self bytes]];
    }
    return image;
}

- (void)thumbnailImageWithSuccess:(void (^)(UIImage *))success
                          failure:(void (^)(void))failure {
    if (thumbnailImage != nil) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                success(thumbnailImage);
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
            CGFloat width = 144.0f;
            CGSize thumbnailSize = CGSizeMake(width, width * fullImage.size.height / fullImage.size.width);
            thumbnailImage = [UIImage imageWithImage:fullImage scaledToSize:thumbnailSize];
            
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (thumbnailImage != nil) {
                    if (success) {
                        success(thumbnailImage);
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
    if (image != nil) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                success(image);
            });
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            UIImage* fullImage = [self image];
            
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (fullImage != nil) {
                    if (success) {
                        success(fullImage);
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
