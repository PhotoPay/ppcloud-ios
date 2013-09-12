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

@property (nonatomic, assign) UIImage* image;

@end

@implementation PPLocalImageDocument

@synthesize image;

- (id)initWithImage:(UIImage*)inImage {
    self = [super initWithBytes:nil
                           type:PPDocumentTypeJPG];
    if (self) {
        image = inImage;
    }
    return self;
}

/** Lazy loading of bytes property because of the UIImage downsampling */
- (NSData*)bytes {
    if (self->bytes_ == nil) {
        self->bytes_ = [UIImage jpegDataWithImage:image
                               scaledToResolution:finalResolution
                                 compressionLevel:0.9];
        
        image = nil; // image is no longer needed
    }
    return self->bytes_;
}

@end
