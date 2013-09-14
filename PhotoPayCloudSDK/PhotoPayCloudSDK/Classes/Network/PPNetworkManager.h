//
//  PPNetworkManager.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPUploadRequestOperation.h"

@class PPLocalDocument;
@class PPRemoteDocument;
@class PPUser;

@interface PPNetworkManager : NSObject

/**
 Operation queue which handles upload requests
 */
@property (nonatomic, strong, readonly) NSOperationQueue* uploadOperationQueue;

/** Upload delegate for all upload requests currently in queue */
@property (nonatomic, weak) id<PPDocumentUploadDelegate> uploadDelegate;

/**
 Abstract
 
 Application that uses PhotoPay Cloud SDK should provide concrete implementation
 */
- (id)httpClient;

/**
 Abstract.
 Factory method for creating UploadRequestOperations.
 
 Should be implemented by the application
 */
- (id<PPUploadRequestOperation>)createUploadRequestForUser:(PPUser *)user
                                             localDocument:(PPLocalDocument*)document
                                                   success:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, PPRemoteDocument *))success
                                                   failure:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, NSError *))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *))canceled;

@end
