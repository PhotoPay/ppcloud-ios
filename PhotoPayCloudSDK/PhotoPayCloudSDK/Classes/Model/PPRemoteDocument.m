//
//  PPRemoteDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPRemoteDocument.h"
#import "PPPhotoPayCloudService.h"

@interface PPRemoteDocument ()

@property (nonatomic, strong, getter = previewImage) UIImage* previewImage;

@property (nonatomic, strong, getter = thumbnailImage) UIImage* thumbnailImage;

@end

@implementation PPRemoteDocument

@synthesize thumbnailImage;
@synthesize previewImage;
@synthesize expectedProcessingTime;

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    self->documentId_ = [PPModelObject initString:dictionary[@"id"]];
    
    self->documentType_ = [PPModelObject initEnum:dictionary[@"documentType"]
                                        enumTable:[PPDocument documentTypeObjectTable]
                                      defaultEnum:PPDocumentTypeJPG];
    
    self->processingType_ = [PPModelObject initEnum:dictionary[@"requestType"]
                                        enumTable:[PPDocument documentProcessingTypeObjectTable]
                                        defaultEnum:PPDocumentProcessingTypeSerbianPhotoInvoice];
    
    self.state = [PPModelObject initEnum:dictionary[@"status"]
                               enumTable:[PPDocument documentStateObjectTable]
                             defaultEnum:PPDocumentStatePending];
    
    self->creationDate_ = [PPModelObject initDate:dictionary[@"creationTime"]
                                      defaultDate:[NSDate date]];
    
    self.expectedProcessingTime = [PPModelObject initNumber:dictionary[@"estimatedMinutesLeft"]
                                              defaultNumber:@(1.0)];
    
    thumbnailImage = nil;
    previewImage = nil;
    
    return self;
};

- (BOOL)reloadWithDocument:(PPDocument*)other {
    PPRemoteDocument* otherRemoteDocument = [other remoteDocument];
    
    if (![self isEqual:otherRemoteDocument]) {
        return NO;
    }
    
    BOOL changed = NO;
    
    if (expectedProcessingTime != otherRemoteDocument.expectedProcessingTime) {
        self.expectedProcessingTime = otherRemoteDocument.expectedProcessingTime;
        changed = YES;
    }
    
    if (thumbnailImage == nil && otherRemoteDocument.thumbnailImage != nil) {
        self.thumbnailImage = otherRemoteDocument.thumbnailImage;
        NSLog(@"Caching thumbnail!");
        changed = YES;
    }
    
    if (previewImage == nil && otherRemoteDocument.previewImage != nil) {
        self.previewImage = otherRemoteDocument.previewImage;
        NSLog(@"Caching preview!");
        changed = YES;
    }
    
    return changed;
}

- (void)setThumbnailImage:(UIImage*)inThumbnailImage {
    thumbnailImage = inThumbnailImage;
}

- (void)setPreviewImage:(UIImage*)inPreviewImage {
    previewImage = inPreviewImage;
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
        [[PPPhotoPayCloudService sharedService] getImageForDocument:self
                                                          imageSize:PPImageSizeThumbnailXXHdpi
                                                        imageFormat:PPImageFormatJpeg
                                                            success:^(UIImage *image) {
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    [self setThumbnailImage:image];
                                                                    if (success) {
                                                                        success(image);
                                                                    }
                                                                });
                                                            } failure:^(NSError *error) {
                                                                thumbnailImage = nil;
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    if (failure) {
                                                                        failure();
                                                                    }
                                                                });
                                                            } canceled:^{
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    if (failure) {
                                                                        failure();
                                                                    }
                                                                });
                                                            }];
    }
}

- (void)previewImageWithSuccess:(void (^)(UIImage* previewImage))success
                        failure:(void (^)(void))failure {
    if (previewImage != nil) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                success(previewImage);
            });
        }
    } else {
        [[PPPhotoPayCloudService sharedService] getImageForDocument:self
                                                          imageSize:PPImageSizeUIXXHdpi
                                                        imageFormat:PPImageFormatJpeg
                                                            success:^(UIImage *image) {
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    [self setPreviewImage:image];
                                                                    if (success) {
                                                                        success(image);
                                                                    }
                                                                });
                                                            } failure:^(NSError *error) {
                                                                previewImage = nil;
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    if (failure) {
                                                                        failure();
                                                                    }
                                                                });
                                                            } canceled:^{
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    if (failure) {
                                                                        failure();
                                                                    }
                                                                });
                                                            }];
    }
}

- (NSString*)description {
    NSString* result = [super description];
    result = [result stringByAppendingFormat:@"Thumbnail %p\n", [self thumbnailImage]];
    result = [result stringByAppendingFormat:@"Preview %p\n", [self previewImage]];
    return result;
}


- (UIImage*)previewImage {
    return previewImage;
}

- (UIImage*)thumbnailImage {
    return thumbnailImage;
}

@end
