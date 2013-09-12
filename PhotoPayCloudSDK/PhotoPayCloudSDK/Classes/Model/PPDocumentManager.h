//
//  PPDocumentManager.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPLocalDocument;

@interface PPDocumentManager : NSObject

/**
 The callback dispatch queue on success. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t successCallbackQueue;

/**
 The callback dispatch queue on failure. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t failureCallbackQueue;

/**
 Designated initializers
 */
- (id)init;

/**
 Performs the saving of a local document to application documents folder
 */
- (void)saveDocument:(PPLocalDocument*)localDocument
             success:(void(^)(PPLocalDocument*localDocument, NSURL* documentUrl))success
             failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure;

@end
