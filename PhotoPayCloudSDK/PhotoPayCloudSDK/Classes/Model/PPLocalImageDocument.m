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
        self->bytes_ = [UIImage jpegDataWithImage:image
                               scaledToResolution:finalResolution
                                 compressionLevel:0.9];
        
        image = nil; // image is no longer needed
    }
    if (self->bytes_ == nil) {
        return [super bytes];
    }
    return self->bytes_;
}

@end
