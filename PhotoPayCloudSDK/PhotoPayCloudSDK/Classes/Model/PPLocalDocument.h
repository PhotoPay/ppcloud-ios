//
//  PPLocalDocument.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPDocument.h"

@class PPDocumentManager;

@protocol PPUploadRequestOperation;

/**
 Encapsulates a local PhotoPay cloud document object 
 */
@interface PPLocalDocument : PPDocument<NSCoding> {
    NSData *bytes_;
}

/**
 Local document can have bytes stored in memory
 */
@property (nonatomic, strong, readonly) NSData *bytes;

/**
 Hash of the userID for the user which owns this document
 */
@property (nonatomic, strong) NSString* ownerIdHash;

/**
 Upload request.
 Exists only when document is uploading.
 */
@property (nonatomic, strong) id<PPUploadRequestOperation> uploadRequest;

/**
 Initializes the local document with concrete bytes
 */
- (id)initWithBytes:(NSData*)inBytes
       documentType:(PPDocumentType)inDocumentType
     processingType:(PPDocumentProcessingType)inProcessingType;

/**
 Persists the local document
 
 In callbacks we have access to NSURL under which the document is stored
 */
- (void)saveUsingDocumentManager:(PPDocumentManager*)documentManager
                         success:(void(^)(PPLocalDocument*localDocument, NSURL* documentUrl))success
                         failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure;

@end
