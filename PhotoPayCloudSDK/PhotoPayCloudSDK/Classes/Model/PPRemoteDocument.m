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

@end

@implementation PPRemoteDocument

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
    
    thumbnailImage_ = nil;
    previewImage_ = nil;
    
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
    
    if (thumbnailImage_ == nil && otherRemoteDocument.thumbnailImage != nil) {
        thumbnailImage_ = otherRemoteDocument.thumbnailImage;
        NSLog(@"Caching thumbnail!");
        changed = YES;
    }
    
    if (previewImage_ == nil && otherRemoteDocument.previewImage != nil) {
        previewImage_ = otherRemoteDocument.previewImage;
        NSLog(@"Caching preview!");
        changed = YES;
    }
    
    return changed;
}

- (void)setThumbnailImage:(UIImage*)inThumbnailImage {
    thumbnailImage_ = inThumbnailImage;
}

- (void)setPreviewImage:(UIImage*)inPreviewImage {
    previewImage_ = inPreviewImage;
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
        [[PPPhotoPayCloudService sharedService] getImageForDocument:self
                                                          imageSize:PPImageSizeThumbnailXXHdpi
                                                        imageFormat:PPImageFormatJpeg
                                                            success:^(UIImage *image) {
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    thumbnailImage_ = image;
                                                                    if (success) {
                                                                        success(image);
                                                                    }
                                                                });
                                                            } failure:^(NSError *error) {
                                                                thumbnailImage_ = nil;
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
    if (previewImage_ != nil) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                success(previewImage_);
            });
        }
    } else {
        [[PPPhotoPayCloudService sharedService] getImageForDocument:self
                                                          imageSize:PPImageSizeUIXXHdpi
                                                        imageFormat:PPImageFormatJpeg
                                                            success:^(UIImage *image) {
                                                                dispatch_async(dispatch_get_main_queue(), ^(){
                                                                    previewImage_ = image;
                                                                    if (success) {
                                                                        success(image);
                                                                    }
                                                                });
                                                            } failure:^(NSError *error) {
                                                                previewImage_ = nil;
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

@end
