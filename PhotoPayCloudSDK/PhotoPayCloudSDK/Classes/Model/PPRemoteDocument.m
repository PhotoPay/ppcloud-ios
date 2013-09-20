//
//  PPRemoteDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPRemoteDocument.h"

@interface PPRemoteDocument ()

@property (nonatomic, strong) UIImage* previewImage;

@property (nonatomic, strong) UIImage* thumbnailImage;

@end

@implementation PPRemoteDocument

@synthesize thumbnailImage;
@synthesize previewImage;

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    NSDictionary *documentDictionary = dictionary[@"document"];
    
    self->documentId_ = [PPModelObject initString:documentDictionary[@"id"]];
    self.state = PPDocumentStateReceived;
    
    NSLog(@"%@", documentDictionary);
    
    return self;
};

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
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (failure) {
                failure();
            }
        });
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
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (failure) {
                failure();
            }
        });
    }
}

@end
