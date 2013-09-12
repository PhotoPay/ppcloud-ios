//
//  PPNetworkManager.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPUploadRequestOperation.h"

@class PPUploadParameters;
@class PPDocument;
@class PPUser;

@interface PPNetworkManager : NSObject

/**
 Operation queue which handles upload requests
 */
@property (nonatomic, strong, readonly) NSOperationQueue* uploadOperationQueue;

/** Upload delegate for all upload requests currently in queue */
@property (nonatomic, weak) id<PPUploadRequestOperationDelegate> uploadDelegate;

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
- (id<PPUploadRequestOperation>)createUploadRequestForUser:(PPUser*)user
                                          uploadParameters:(PPUploadParameters*)uploadParameters
                                                   success:(void (^)(id<PPUploadRequestOperation> request, PPDocument* document))success
                                                   failure:(void (^)(id<PPUploadRequestOperation> request, NSError *error))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation> request))canceled;


@end
