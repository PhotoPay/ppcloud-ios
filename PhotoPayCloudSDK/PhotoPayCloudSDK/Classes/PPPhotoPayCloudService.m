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
#import "PPDocumentsTableDataSource.h"

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
                    delegate:(id<PPDocumentUploadDelegate>)delegate
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
@synthesize uploadDelegate;

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

- (void)initializeForUser:(PPUser*)inUser withNetworkManager:(PPNetworkManager*)inNetworkManager {
    if (state != PPPhotoPayCloudServiceStateUninitialized) {
        NSLog(@"PhotoPayCloudService is already initialized. Returining immediately.");
        return;
    }
    
    if (inUser == nil) {
        NSLog(@"Valid user must be specified for initialization. This one is nil. Returining immediately.");
        return;
    }
    
    if (inNetworkManager == nil) {
        NSLog(@"Valid user network manager be specified for initialization. This one is nil. Returining immediately.");
        return;
    }
    
    user = inUser;
    networkManager = inNetworkManager;
    [networkManager setUploadDelegate:[self uploadDelegate]];
    
    state = PPPhotoPayCloudServiceStateReady;
    
    [self checkExistingUploadQueue];
    
    NSLog(@"Initialized!");
}

- (void)uninitialize {
    user = nil;
    networkManager = nil;
    self.state = PPPhotoPayCloudServiceStateUninitialized;
    
    for (int i = 0; i < [[[self documentUploadQueue] elements] count]; i++) {
        [[[[[[self documentUploadQueue] elements] objectAtIndex:i] localDocument] uploadRequest] cancel];
    }
    
    NSLog(@"Uninitialized!");
}

- (void)checkExistingUploadQueue {
    NSLog(@"Checking!");
    // deserialize the request queue for this user
    NSString* userIdHash = [[self user] userIdHash];
    NSLog(@"User id hash = %@", userIdHash);
    documentUploadQueue = [PPLocalDocumentUploadQueue queueForUserIdHash:userIdHash];
    NSLog(@"Queue length = %d", [[self documentUploadQueue] count]);
    
    if (documentUploadQueue == nil || [documentUploadQueue count] == 0) {
        // we don't have any existing uploadsf
        documentUploadQueue = [[PPLocalDocumentUploadQueue alloc] init];
        self.state = PPPhotoPayCloudServiceStateReady;
        NSLog(@"READY");
    } else {
        self.state = PPPhotoPayCloudServiceStatePaused;
        NSLog(@"PAUSED");
    }
   
}

- (void)setUploadDelegate:(id<PPDocumentUploadDelegate>)inUploadDelegate {
    uploadDelegate = inUploadDelegate;
    [[self networkManager] setUploadDelegate:[self uploadDelegate]];
}

- (void)uploadStoredDocument:(PPLocalDocument*)localDocument
                    delegate:(id<PPDocumentUploadDelegate>)delegate
                     success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
                     failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
                    canceled:(void (^)(PPLocalDocument* localDocument))canceled {
    // called in upload dispatch queue which makes main free for UI
    
    // set document data
    [localDocument setOwnerIdHash:[[self user] userIdHash]];
    
    // create the upload request
    id<PPUploadRequestOperation> uploadRequest =
        [[self networkManager] createUploadRequestForUser:[self user]
                                            localDocument:localDocument
                                                  success:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument) {
                                                      
                                                      [[self documentUploadQueue] remove:localDocument];
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          state = PPPhotoPayCloudServiceStateReady;
                                                          NSLog(@"READY");
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                                          [[self dataSource] swapLocalDocument:localDocument
                                                                            withRemoteDocument:remoteDocument];
                                                          NSLog(@"Document list refreshed with successful upload!");
                                                      });
                                                      
                                                      if (success) {
                                                          dispatch_async(self.successDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                              success(localDocument, remoteDocument);
                                                              [localDocument setUploadRequest:nil];
                                                          });
                                                      } else {
                                                          [localDocument setUploadRequest:nil];
                                                      }
                                                  }
                                                  failure:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument, NSError *error) {
                                                      
                                                      localDocument.state = PPDocumentStateUploadFailed;
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          state = PPPhotoPayCloudServiceStateReady;
                                                          NSLog(@"READY");
                                                      }
                                                      NSLog(@"Queue length = %d", [[self documentUploadQueue] count]);
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                                          [[self dataSource] insertItems:[[NSArray alloc] initWithObjects:localDocument, nil]];
                                                          NSLog(@"Document list refreshed with failed upload!");
                                                      });
                                                      
                                                      if (failure) {
                                                          dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                              failure(localDocument, error);
                                                              [localDocument setUploadRequest:nil];
                                                          });
                                                      } else {
                                                          [localDocument setUploadRequest:nil];
                                                      }
                                                  }
                                                 canceled:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument) {
                                                     
                                                     localDocument.state = PPDocumentStateUploadFailed;
                                                     if ([[self documentUploadQueue] count] == 0) {
                                                         NSLog(@"READY");
                                                         state = PPPhotoPayCloudServiceStateReady;
                                                     }
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^() {
                                                         [[self dataSource] insertItems:[[NSArray alloc] initWithObjects:localDocument, nil]];
                                                         NSLog(@"Document list refreshed with canceled upload!");
                                                     });
                                                     
                                                     if (canceled) {
                                                         dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                             canceled(localDocument);
                                                             [localDocument setUploadRequest:nil];
                                                         });
                                                     } else {
                                                         [localDocument setUploadRequest:nil];
                                                     }
                                                 }];
    
    [uploadRequest setDelegate:delegate];
    [localDocument setUploadRequest:uploadRequest];
    localDocument.state = PPDocumentStateUploading;
    
    // enqueue upload parameters queue;
    // also serializes upload parameters object to documents directory
    BOOL saveSuccessful = [[self documentUploadQueue] insert:localDocument];
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
    
    state = PPPhotoPayCloudServiceStateUploading;
    NSLog(@"UPLOADING");
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSLog(@"Document list refreshing with document which started uploading!");
        [[self dataSource] insertItems:[[NSArray alloc] initWithObjects:localDocument, nil]];
    });
    
    // add it to the operation queue
    [[[self networkManager] uploadOperationQueue] addOperation:uploadRequest];
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
              delegate:(id<PPDocumentUploadDelegate>)delegate
               success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
               failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
              canceled:(void (^)(PPLocalDocument* localDocument))canceled {
    
    if (document == nil) {
        // invalid document
        NSLog(@"Trying to upload NIL document, returning immediately");
        return;
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
                                                         delegate:delegate
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
                              delegate:delegate
                               success:success
                               failure:failure
                              canceled:canceled];
        });
    }
}

- (void)uploadPendingDocuments {
    if ([self state] == PPPhotoPayCloudServiceStatePaused) {
        NSLog(@"Delegate is null? %@", [self uploadDelegate] == nil ? @"YES" : @"NO");
        for (PPLocalDocument* document in [[self documentUploadQueue] elements]) {
            [self uploadDocument:document
                        delegate:[self uploadDelegate]
                         success:nil
                         failure:nil
                        canceled:nil];
        }
    }
}

- (void)deletePendingDocumentsWithError:(NSError**)error {
    for (int i = [[self documentUploadQueue] count] - 1; i >= 0 ; i--) {
        PPLocalDocument *localDocument = [[[self documentUploadQueue] elements] objectAtIndex:i];
        [self deleteDocument:localDocument error:error];
    }
    [self setState:PPPhotoPayCloudServiceStateReady];
    NSLog(@"READY");
}

- (void)deleteDocument:(PPDocument*)document
                 error:(NSError**)error {
    PPLocalDocument* localDocument = [document localDocument];
    if (localDocument != nil) {
        [[self documentManager] deleteDocument:localDocument error:error];
        [[self documentUploadQueue] remove:localDocument];
    } else {
//        PPRemoteDocument* remoteDocument = [document remoteDocument];
    }
    
    NSLog(@"Queue length = %d", [[self documentUploadQueue] count]);
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSLog(@"Document list refreshed with deleted document!");
        [[self dataSource] removeItems:[[NSArray alloc] initWithObjects:localDocument, nil]];
    });
}

- (void)requestDocuments:(PPDocumentState)documentStates {
    NSLog(@"Requesting documents!");
    
    static PPDocumentState lastDocumentStates = PPDocumentStateUnknown;
    if (documentStates == lastDocumentStates) { // document states are the same as last presented, so we're fine and dandy, just return
        return;
    }
    
    // find all documents currently in data source which aren't in the state given by documentStates
    NSMutableArray *documentsToRemove = [[NSMutableArray alloc] init];
    for (PPDocument* document in [[self dataSource] items]) {
        if (([document state] & documentStates) == 0) {
            [documentsToRemove addObject:document];
        }
    }
    
    // these should be removed
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[self dataSource] removeItems:documentsToRemove];
    });
   
    
    // find all documents currently in document upload queue which are in the state given by document states
    NSMutableArray *documentsToAdd = [[NSMutableArray alloc] init];
    for (PPDocument* document in [[self documentUploadQueue] elements]) {
        if ([document state] & documentStates) {
            [documentsToAdd addObject:document];
        }
    }
    
    // these should be added
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[self dataSource] insertItems:documentsToAdd];
    });
}

@end
