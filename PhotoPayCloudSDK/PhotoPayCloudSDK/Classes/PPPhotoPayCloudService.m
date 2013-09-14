//
//  PPPhotoPayCloudService.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPPhotoPayCloudService.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import "PPUser.h"
#import "PPDocumentManager.h"
#import "PPLocalDocumentUploadQueue.h"
#import "PPNetworkManager.h"

/** Private extensions to PhotoPayCloud Service */
@interface PPPhotoPayCloudService ()

/**
 This queue contains a list of PPLocalDocument objects. These represent all LocalDocuments which are
 still uploading and not yet sent to the PhotoPay Cloud web application.
 */
@property (nonatomic, strong) PPLocalDocumentUploadQueue* documentUploadQueue;

/** Serial dispatch queue for upload requests */
@property (nonatomic, assign) dispatch_queue_t uploadDispatchQueue;

/** Override of the state property. Inside of the class it's changeable */
@property (nonatomic) PPPhotoPayCloudServiceState state;

/**
 Checks if any existing upload queues wait for continuation
 */
- (void)checkExistingUploadQueue;

/**
 Method which sends a local document which is already saved to documents directory
 
 This method creates and dispatches the actual upload request
 */
- (void)uploadStoredDocument:(PPLocalDocument*)localDocument
                     success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
                     failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
                    canceled:(void (^)(PPLocalDocument* localDocument))canceled;

/**
 Method which reports storing local document to documents directory has failed
 */
- (void)storingFailed:(PPLocalDocument*)localDocument
                error:(NSError*)error
              failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure;

@end

@implementation PPPhotoPayCloudService

@synthesize user;
@synthesize state;
@synthesize documentManager;
@synthesize networkManager;
@synthesize uploadDispatchQueue;
@synthesize successDispatchQueue;
@synthesize failureDispatchQueue;
@synthesize documentUploadQueue;

+ (PPPhotoPayCloudService*)sharedService {
    static PPPhotoPayCloudService* sharedService = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    
    return sharedService;
}

- (id)init {
    self = [super init];
    if (self) {
        documentManager = [[PPDocumentManager alloc] init];
        
        // network manager is not set in the beginning
        networkManager = nil;
        
        // dispatch queue for upload requests
        self.uploadDispatchQueue = dispatch_queue_create("net.photopay.cloud.sdk.upload", NULL);
        [documentManager setSuccessCallbackQueue:uploadDispatchQueue];
        [documentManager setFailureCallbackQueue:uploadDispatchQueue];
        
        // default values for success and failure dispatch queues
        successDispatchQueue = nil;
        failureDispatchQueue = nil;
        
        // in the beginning, upload upload paramteres are empty
        documentUploadQueue = [[PPLocalDocumentUploadQueue alloc] init];
        
        // uploading is ready
        state = PPPhotoPayCloudServiceStateUninitialized;
        
        // user is not set. Please set the user to be able to request uploads.
        user = nil;
    }
    return self;
}

#pragma mark dispatch queue memory management (requires special case for pre iOS6)

- (void)dealloc {
    if (successDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(successDispatchQueue);
#endif
        successDispatchQueue = NULL;
    }
    
    if (failureDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(failureDispatchQueue);
#endif
        failureDispatchQueue = NULL;
    }
    
    if (uploadDispatchQueue) { // release old queue
#if !OS_OBJECT_USE_OBJC
        dispatch_release(uploadDispatchQueue);
#endif
        uploadDispatchQueue = NULL;
    }
}

/** Correctly handle pre-iOS6 case by using dispatch release/retain with dispatch queues */
- (void)setSuccessDispatchQueue:(dispatch_queue_t)inSuccessDispatchQueue {
    if (inSuccessDispatchQueue != successDispatchQueue) {
        if (successDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(successDispatchQueue);
#endif
            successDispatchQueue = NULL;
        }
        
        if (inSuccessDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(inSuccessDispatchQueue);
#endif
            successDispatchQueue = inSuccessDispatchQueue;
        }
    }
}

/** Correctly handle pre-iOS6 case by using dispatch release/retain with dispatch queues */
- (void)setFailureDispatchQueue:(dispatch_queue_t)inFailureDispatchQueue {
    if (inFailureDispatchQueue != failureDispatchQueue) {
        if (failureDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(failureDispatchQueue);
#endif
            failureDispatchQueue = NULL;
        }
        
        if (inFailureDispatchQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(inFailureDispatchQueue);
#endif
            failureDispatchQueue = inFailureDispatchQueue;
        }
    }
}

/** Correctly handle pre-iOS6 case by using dispatch release/retain with dispatch queues */
- (void)setUploadDispatchQueue:(dispatch_queue_t)inUploadDispatchQueue {
    if (inUploadDispatchQueue != uploadDispatchQueue) {
        if (uploadDispatchQueue) { // release old queue
#if !OS_OBJECT_USE_OBJC
            dispatch_release(uploadDispatchQueue);
#endif
            uploadDispatchQueue = NULL;
        }
        
        if (inUploadDispatchQueue) { // retain new queue
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(inUploadDispatchQueue);
#endif
            uploadDispatchQueue = inUploadDispatchQueue;
        }
    }
}

- (void)setUser:(PPUser *)inUser {
    user = inUser;
    
    if (self.networkManager != nil && self.user != nil) {
        [self checkExistingUploadQueue];
    } else {
        self.state = PPPhotoPayCloudServiceStateUninitialized;
    }
}

- (void)setNetworkManager:(PPNetworkManager *)inNetworkManager {
    networkManager = inNetworkManager;
    
    if (self.networkManager != nil && self.user != nil) {
        [self checkExistingUploadQueue];
    } else {
        self.state = PPPhotoPayCloudServiceStateUninitialized;
    }
}

- (void)checkExistingUploadQueue {
    // deserialize the request queue for this user
    NSString* userIdHash = [[self user] userIdHash];
    documentUploadQueue = [PPLocalDocumentUploadQueue queueForUserIdHash:userIdHash];
    
    if (documentUploadQueue == nil) {
        // we don't have any existing uploadsf
        documentUploadQueue = [[PPLocalDocumentUploadQueue alloc] init];
        self.state = PPPhotoPayCloudServiceStateReady;
    } else {
        self.state = PPPhotoPayCloudServiceStatePaused;
    }
}

- (void)uploadStoredDocument:(PPLocalDocument*)localDocument
                     success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
                     failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
                    canceled:(void (^)(PPLocalDocument* localDocument))canceled {
    // called in upload dispatch queue which makes main free for UI
    
    // set document data
    [localDocument setOwnerIdHash:[[self user] userIdHash]];
    
    NSLog(@"We are uploading document:\n %@", [localDocument toString]);
    
    // create the upload request
    id<PPUploadRequestOperation> uploadRequest =
        [[self networkManager] createUploadRequestForUser:[self user]
                                            localDocument:localDocument
                                                  success:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument) {
                                                      
                                                      [[self documentUploadQueue] remove:localDocument];
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          state = PPPhotoPayCloudServiceStateReady;
                                                      }
                                                      
                                                      if (success) {
                                                          dispatch_async(self.successDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                              success(localDocument, remoteDocument);
                                                          });
                                                      }
                                                  }
                                                  failure:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument, NSError *error) {
                                                      
                                                      [[self documentUploadQueue] remove:localDocument];
                                                      localDocument.state = PPDocumentStateStored;
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          state = PPPhotoPayCloudServiceStateReady;
                                                      }
                                                      
                                                      if (failure) {
                                                          dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                              failure(localDocument, error);
                                                          });
                                                      }
                                                  }
                                                 canceled:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument) {
                                                     
                                                     [[self documentUploadQueue] remove:localDocument];
                                                     localDocument.state = PPDocumentStateStored;
                                                     if ([[self documentUploadQueue] count] == 0) {
                                                         state = PPPhotoPayCloudServiceStateReady;
                                                     }
                                                     
                                                     if (canceled) {
                                                         dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                             canceled(localDocument);
                                                         });
                                                     }
                                                 }];
    
    // enqueue upload parameters queue;
    // also serializes upload parameters object to documents directory
    BOOL saveSuccessful = [[self documentUploadQueue] enqueue:localDocument];
    if (!saveSuccessful) {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadCannotStoreRequest";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2003
                                         userInfo:userInfo];
        
        if (failure) {
            failure(localDocument, error);
        }
        
        return;
    }
    
    localDocument.state = PPDocumentStateUploading;
    
    state = PPPhotoPayCloudServiceStateUploading;
    
    // add it to the operation queue
    [[[self networkManager] uploadOperationQueue] addOperation:uploadRequest];
    
    // resets the upload delegate so it also receives events about the new request
    [[self networkManager] setUploadDelegate:[[self networkManager] uploadDelegate]];
}

- (void)storingFailed:(PPLocalDocument*)localDocument
                error:(NSError*)error
              failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure {
    
    // simply report failure on failure dispatch queue
    dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
        failure(localDocument, error);
    });
}

- (void)uploadDocument:(PPLocalDocument*)document
               success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
               failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
              canceled:(void (^)(PPLocalDocument* localDocument))canceled {
    
    if (document == nil) {
        // invalid document
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Input document is nil"
                                     userInfo:nil];
    }
    
    if ([self state] == PPPhotoPayCloudServiceStateUninitialized) {
        NSString* reason = @"Unknown";
        if ([self user] == nil) {
            reason = @"User object is not provided!";
        } else if ([self networkManager] == nil) {
            reason = @"Network manager is not provided!";
        }
        // invalid state
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Cannot process request when PPPhotoPayCloudService object is uninitialized! Reason: %@", reason]
                                     userInfo:nil];
    }
    
    
    if ([document state] == PPDocumentStateCreated) {
        // Save local document file do documents directory
        // document saving is done in document manager's serial dispatch queue
        // this will not block the calling queue
        [document saveUsingDocumentManager:[self documentManager]
                                   success:^(PPLocalDocument*localDocument, NSURL* documentUrl) {
                                       // local document is already stored
                                       // repeate request for stored document
                                       [self uploadStoredDocument:document
                                                          success:success
                                                          failure:failure
                                                         canceled:canceled];
                                   }
                                   failure:^(PPLocalDocument*localDocument, NSError*error) {
                                       [self storingFailed:localDocument
                                                     error:error
                                                   failure:failure];
                                   }];
    } else {
        // uploads are always performed on upload dispatch queue
        dispatch_async(uploadDispatchQueue, ^(){
            // local document is already stored
            // repeate request for stored document
            [self uploadStoredDocument:document
                               success:success
                               failure:failure
                              canceled:canceled];
        });
    }
}

- (void)getDocuments:(PPDocumentState)documentStates
             success:(void (^)(NSArray *))success
             failure:(void (^)(NSError *))failure
            canceled:(void (^)(void))canceled {
    
}

@end
