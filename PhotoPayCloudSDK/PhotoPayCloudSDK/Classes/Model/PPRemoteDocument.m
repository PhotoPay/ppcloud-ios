//
//  PPRemoteDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPRemoteDocument.h"
#import "PPPhotoPayCloudService.h"
#import "PPDocumentManager.h"
#import "UIApplication+Documents.h"
#import "PPScanResult.h"
#import "PPScanResultAustria.h"
#import "PPScanResultSerbia.h"

@interface PPRemoteDocument ()

- (id)getDocumentFromByteArray:(NSData*)data;

@end

@implementation PPRemoteDocument

@synthesize expectedProcessingTime;

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return self;
    }
    
    self->documentId_ = [PPModelObject initString:dictionary[@"id"]];
    
    self->documentType_ = [PPModelObject initEnum:dictionary[@"documentType"]
                                        enumTable:[PPDocument documentTypeObjectTable]
                                      defaultEnum:PPDocumentTypeUnknown];
    
    self->cachedDocumentUrl_ = nil;

    
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
    if ([self.expectedProcessingTime doubleValue] < 1.0) {
        self.expectedProcessingTime = @(1.0);
    }
    
    Class scanResultClass;
    switch (processingType_) {
        case PPDocumentProcessingTypeAustrianPDFInvoice:
        case PPDocumentProcessingTypeAustrianPhotoInvoice:
            scanResultClass = [PPScanResultAustria class];
            break;
        case PPDocumentProcessingTypeSerbianPhotoInvoice:
        case PPDocumentProcessingTypeSerbianPDFInvoice:
        default:
            scanResultClass = [PPScanResultSerbia class];
            break;
    }
    self.scanResult = [[scanResultClass alloc] initWithDictionary:dictionary[@"candidateList"]];
    
    thumbnailImage_ = nil;
    previewImage_ = nil;
    
    return self;
};

- (id)copyWithZone:(NSZone *)zone {
    PPRemoteDocument *another = [super copyWithZone:zone];
    another->expectedProcessingTime = self->expectedProcessingTime;
    another->_scanResult = self->_scanResult;
    return another;
}

- (BOOL)reloadWithDocument:(PPDocument*)other {
    PPRemoteDocument* otherRemoteDocument = [other remoteDocument];
    
    if (![self isEqual:otherRemoteDocument]) {
        return NO;
    }
    
    BOOL changed = NO;
    
    if (self.state != other.state) {
        self.state = other.state;
        changed = YES;
    }
    
    if (self.documentType == PPDocumentTypeUnknown) {
        self.documentType = otherRemoteDocument.documentType;
    }
    
    self->processingType_ = otherRemoteDocument.processingType;
    
    if (![expectedProcessingTime isEqual:otherRemoteDocument.expectedProcessingTime]) {
        self.expectedProcessingTime = otherRemoteDocument.expectedProcessingTime;
        changed = YES;
    }
    
    if ([self.scanResult isEmpty] && ![otherRemoteDocument.scanResult isEmpty]) {
        self.scanResult = otherRemoteDocument.scanResult;
        changed = YES;
    }
    
    if (thumbnailImage_ == nil && otherRemoteDocument.thumbnailImage != nil) {
        thumbnailImage_ = otherRemoteDocument.thumbnailImage;
        changed = YES;
    }
    
    if (previewImage_ == nil && otherRemoteDocument.previewImage != nil) {
        previewImage_ = otherRemoteDocument.previewImage;
        changed = YES;
    }
    
    if (cachedDocumentUrl_ == nil && otherRemoteDocument.cachedDocumentUrl != nil) {
        cachedDocumentUrl_ = otherRemoteDocument.cachedDocumentUrl;
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
                                                          imageSize:PPImageSizeUIXXXHdpi
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

- (void)documentBytesWithSuccess:(void (^)(NSData* bytes))success
                         failure:(void (^)(void))failure {
    [[PPPhotoPayCloudService sharedService] getDocumentData:self
                                                    success:^(NSData *bytes) {
                                                        dispatch_async(dispatch_get_main_queue(), ^(){
                                                            if (success) {
                                                                success(bytes);
                                                            }
                                                        });
                                                    } failure:^(NSError *error) {
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

- (NSString*)description {
    NSString* result = [super description];
    result = [result stringByAppendingFormat:@"Thumbnail %p\n", [self thumbnailImage]];
    result = [result stringByAppendingFormat:@"Preview %p\n", [self previewImage]];
    result = [result stringByAppendingFormat:@"Scan result: %@\n", [self scanResult]];
    return result;
}

- (id)getDocumentFromByteArray:(NSData*)data {
    id document = nil;
    switch (documentType_) {
        default: {
            document = [UIImage imageWithData:data];
            break;
        }
    }
    return document;
}

@end
