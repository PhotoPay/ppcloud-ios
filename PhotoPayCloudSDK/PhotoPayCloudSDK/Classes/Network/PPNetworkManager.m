//
//  PPNetworkManager.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPNetworkManager.h"
#import "PPRemoteDocument.h"
#import "PPLocalDocument.h"

@interface PPNetworkManager ()

/**
 Operation queue which handles upload requests
 */
@property (nonatomic, strong) NSOperationQueue* uploadOperationQueue;

@end

@implementation PPNetworkManager

@synthesize uploadDelegate;
@synthesize uploadOperationQueue;

- (id)init {
    self = [super init];
    if (self) {
        uploadOperationQueue = [[NSOperationQueue alloc] init];
        uploadOperationQueue.name = @"PhotoPay Cloud Upload Queue";
    }
    return self;
}

- (id)httpClient {
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (id<PPUploadRequestOperation>)createUploadRequestForUser:(PPUser *)user
                                             localDocument:(PPLocalDocument*)document
                                                   success:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, PPRemoteDocument *))success
                                                   failure:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, NSError *))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *))canceled {
    
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)setUploadDelegate:(id<PPDocumentUploadDelegate>)inUploadDelegate {
    uploadDelegate = inUploadDelegate;
    for (id<PPUploadRequestOperation> operation in self.uploadOperationQueue.operations) {
        operation.delegate = uploadDelegate;
    }
}

@end
