//
//  PPNetworkManager.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPNetworkManager.h"
#import "PPRemoteDocument.h"

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
                                          uploadParameters:(PPUploadParameters *)uploadParameters
                                                   success:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, PPRemoteDocument *))success
                                                   failure:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, NSError *))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *))canceled {
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)setUploadDelegate:(id<PPUploadRequestOperationDelegate>)inUploadDelegate {
    if (inUploadDelegate == nil) {
        NSLog(@"Setting upload delegate to NIL!");
    } else {
        NSLog(@"Setting upload delegate!");
    }
    uploadDelegate = inUploadDelegate;
    for (id<PPUploadRequestOperation> operation in self.uploadOperationQueue.operations) {
        NSLog(@"One delegate set!");
        operation.delegate = uploadDelegate;
    }
}

@end
