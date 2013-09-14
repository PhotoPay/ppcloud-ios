//
//  PPDocumentManager.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentManager.h"
#import "PPLocalDocument.h"
#import "UIApplication+Documents.h"
#import "NSString+Factory.h"

@interface PPDocumentManager ()

@property (nonatomic, assign) dispatch_queue_t documentQueue;

/**
 Returns the extension of the current document
 
 Extension is determined by documentType enum
 */
+ (NSString*)fileExtensionForType:(PPDocumentType)type;

@end

@implementation PPDocumentManager

@synthesize successCallbackQueue;
@synthesize failureCallbackQueue;
@synthesize documentQueue;

- (id)init {
    self = [super init];
    if (self) {
        successCallbackQueue = nil;
        failureCallbackQueue = nil;
        self.documentQueue = dispatch_queue_create("net.photopay.cloud.sdk.document", NULL);
    }
    return self;
}

- (void)dealloc {
    if (successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(successCallbackQueue);
#endif
        successCallbackQueue = NULL;
    }
    
    if (failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(failureCallbackQueue);
#endif
        failureCallbackQueue = NULL;
    }
    
    if (documentQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(documentQueue);
#endif
        documentQueue = NULL;
    }
}

/** Correctly handle pre-iOS6 case by using dispatch release/retain with dispatch queues */
- (void)setSuccessCallbackQueue:(dispatch_queue_t)inSuccessCallbackQueue {
    if (inSuccessCallbackQueue != successCallbackQueue) {
        if (successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(successCallbackQueue);
#endif
            successCallbackQueue = NULL;
        }
        
        if (inSuccessCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(inSuccessCallbackQueue);
#endif
            successCallbackQueue = inSuccessCallbackQueue;
        }
    }
}

/** Correctly handle pre-iOS6 case by using dispatch release/retain with dispatch queues */
- (void)setFailureCallbackQueue:(dispatch_queue_t)inFailureCallbackQueue {
    if (inFailureCallbackQueue != failureCallbackQueue) {
        if (failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(failureCallbackQueue);
#endif
            failureCallbackQueue = NULL;
        }
        
        if (inFailureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(inFailureCallbackQueue);
#endif
            failureCallbackQueue = inFailureCallbackQueue;
        }
    }
}

/** Correctly handle pre-iOS6 case by using dispatch release/retain with dispatch queues */
- (void)setDocumentQueue:(dispatch_queue_t)inDocumentQueue {
    if (inDocumentQueue != documentQueue) {
        if (documentQueue) { // release old queue
#if !OS_OBJECT_USE_OBJC
            dispatch_release(documentQueue);
#endif
            documentQueue = NULL;
        }
        
        if (inDocumentQueue) { // retain new queue
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(inDocumentQueue);
#endif
            documentQueue = inDocumentQueue;
        }
    }
}

- (void)saveDocument:(PPLocalDocument*)localDocument
             success:(void(^)(PPLocalDocument*localDocument, NSURL* documentUrl))success
             failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure {
    
    dispatch_async(documentQueue, ^{
        NSString* filename = [PPDocumentManager generateUniqueFilenameForType:[localDocument documentType]];
        NSError * __autoreleasing error;
        NSURL *url = [UIApplication createFileWithData:[localDocument bytes]
                                              filename:filename
                                                 error:&error];
        
        NSError *returnedError = [error copy];
        if (url != nil) {
            dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                if (success) {
                    success(localDocument, url);
                }
            });
        } else {
            dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(localDocument, returnedError);
                }
            });
        }
    });
}

+ (NSString*)fileExtensionForType:(PPDocumentType)type {
    switch (type) {
        case PPDocumentTypePNG:
            return @"png";
            break;
        case PPDocumentTypeJPG:
            return @"jpg";
            break;
        case PPDocumentTypeGIF:
            return @"gif";
            break;
        case PPDocumentTypeTIFF:
            return @"tiff";
            break;
        case PPDocumentTypePDF:
            return @"pdf";
            break;
        case PPDocumentTypeHTML:
            return @"html";
            break;
        case PPDocumentTypeXLS:
            return @"xls";
            break;
        case PPDocumentTypeDOC:
            return @"doc";
            break;
        case PPDocumentTypeTXT:
            return @"txt";
            break;
        case PPDocumentTypeXML:
            return @"xml";
            break;
        case PPDocumentTypeJSON:
            return @"json";
            break;
        default:
            // invalid document type
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"%u is not a valid document type", type]
                                         userInfo:nil];
            break;
    }
}

+ (NSString*)generateUniqueFilenameForType:(PPDocumentType)type {
    NSString* uuid = [NSString UUID];
    NSString* extension = [PPDocumentManager fileExtensionForType:type];
    return [NSString stringWithFormat:@"%@.%@", uuid, extension];
}

@end
