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

@interface PPDocumentManager ()

@property (nonatomic, assign) dispatch_queue_t documentQueue;

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

+ (NSURL*)urlForFilename:(NSString*)filename {
    NSError * __autoreleasing error = nil;
    NSURL* documentsDir = [UIApplication applicationDocumentsDirectoryWithError:&error];
    if (documentsDir == nil || error != nil) {
        return nil;
    }
    
    return [documentsDir URLByAppendingPathComponent:filename];
}

- (void)saveDocument:(PPLocalDocument*)localDocument atUrl:(NSURL*)documentUrl
             success:(void(^)(PPLocalDocument*localDocument))success
             failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure {
    
    dispatch_async(documentQueue, ^{
        NSError * __autoreleasing error;
        NSURL *url = [UIApplication createFileWithData:[localDocument bytes]
                                                   url:documentUrl
                                                 error:&error];
        
        NSError *returnedError = [error copy];
        if (url != nil) {
            dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                if (success) {
                    success(localDocument);
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

- (BOOL)deleteDocument:(PPLocalDocument*)localDocument
                 error:(NSError**)error {
    return [UIApplication deleteFileWithUrl:[localDocument cachedDocumentUrl]
                                      error:error];
}

@end
