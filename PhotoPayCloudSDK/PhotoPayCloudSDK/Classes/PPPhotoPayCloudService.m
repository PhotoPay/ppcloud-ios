//
//  PPPhotoPayCloudService.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPPhotoPayCloudService.h"
#import "PPDocumentsFetchDelegate.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import "PPUser.h"
#import "PPDocumentManager.h"
#import "PPLocalDocumentUploadQueue.h"
#import "PPNetworkManager.h"
#import "PPDocumentsTableDataSource.h"
#import "UIApplication+Documents.h"
#import "PPBaseResponse.h"
#import "Utils/NSData+DeviceToken.h"

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

- (void)setDeviceToken:(NSData*)data {
    _deviceToken = data;
    [self registerPushNotification];
}

- (void)registerPushNotification {
    if ([self deviceToken] != nil) {
        NSString* deviceTokenString = [_deviceToken stringFromDeviceToken];
        if (deviceTokenString != nil) {
            [self registerPushNotificationToken:deviceTokenString];
        } else {
            NSLog(@"Device token is null!");
        }
    }
}

- (id)init {
    self = [super init];
    if (self) {
        documentManager = [[PPDocumentManager alloc] init];
        
        // create a default data source
        _dataSource = [[PPDocumentsTableDataSource alloc] init];
        
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
        [self setState:PPPhotoPayCloudServiceStateUninitialized];
        
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

- (void)setState:(PPPhotoPayCloudServiceState)state {
    if (_state != PPPhotoPayCloudServiceStateUninitialized) {
        _state = state;
    } else {
        NSLog(@"PhotoPayCloudService State transition from %u to %u is not allowed.", _state, state);
    }
}

- (void)initializeForUser:(PPUser*)inUser withNetworkManager:(PPNetworkManager*)inNetworkManager {
    if ([self state] != PPPhotoPayCloudServiceStateUninitialized) {
        NSLog(@"PhotoPayCloudService is already initialized. Returning immediately.");
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
    
    _state = PPPhotoPayCloudServiceStateReady;
    
    [self checkExistingUploadQueue];
    
    NSLog(@"PhotoPayCloud initialized");

    [self registerPushNotification];
}

- (void)uninitialize {
    user = nil;
    networkManager = nil;
    self.state = PPPhotoPayCloudServiceStateUninitialized;
    
    for (int i = 0; i < [[[self documentUploadQueue] elements] count]; i++) {
        [[[[[[self documentUploadQueue] elements] objectAtIndex:i] localDocument] uploadRequest] cancel];
    }
    
    self.uploadDelegate = nil;
    
    NSLog(@"PhotoPayCloud uninitialized");
}

- (BOOL)isServiceUnavailable {
    if (self.state == PPPhotoPayCloudServiceStateUninitialized) {
        NSLog(@"PPCloud service is uninitialized!");
        return YES;
    }
    return NO;
}

- (void)checkExistingUploadQueue {
    if ([self isServiceUnavailable]) {
        return;
    }
    
    // deserialize the request queue for this user
    NSString* userIdHash = [[self user] userIdHash];
    documentUploadQueue = [PPLocalDocumentUploadQueue queueForUserIdHash:userIdHash];
    
    if (documentUploadQueue == nil || [documentUploadQueue count] == 0) {
        // we don't have any existing uploadsf
        documentUploadQueue = [[PPLocalDocumentUploadQueue alloc] init];
        self.state = PPPhotoPayCloudServiceStateReady;
    } else {
        self.state = PPPhotoPayCloudServiceStatePaused;
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
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    // set document data
    [localDocument setOwnerIdHash:[[self user] userIdHash]];
    
    // create the upload request
    id<PPUploadRequestOperation> uploadRequest =
        [[self networkManager] createUploadRequestForUser:[self user]
                                            localDocument:localDocument
                                                  success:^(id<PPUploadRequestOperation> operation, PPBaseResponse *response) {
                                                      PPRemoteDocument* remoteDocument = [response document];
                                                      [[self documentUploadQueue] remove:localDocument];
                                                      [[self documentManager] deleteDocument:localDocument error:nil];
                                                      
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          [self setState:PPPhotoPayCloudServiceStateReady];
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                                          [remoteDocument setPreviewImage:[localDocument previewImage]];
                                                          [remoteDocument setThumbnailImage:[localDocument thumbnailImage]];
                                                          [remoteDocument setCreationDate:[localDocument creationDate]];
                                                          
                                                          [[self dataSource] reloadItems:[[NSArray alloc] initWithObjects:localDocument, nil]
                                                                               withItems:[[NSArray alloc] initWithObjects:remoteDocument, nil]];
                                                          [[localDocument delegate] documentDidChangeState:remoteDocument];
                                                      });
                                                      
                                                      if (success) {
                                                          dispatch_async(self.successDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                              success(localDocument, remoteDocument);
                                                              [localDocument setUploadRequest:nil];
                                                          });
                                                      } else {
                                                          [localDocument setUploadRequest:nil];
                                                      }
                                                  } failure:^(id<PPUploadRequestOperation> operation, PPBaseResponse *response, NSError *error) {
                                                      localDocument.state = PPDocumentStateUploadFailed;
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          [self setState:PPPhotoPayCloudServiceStateReady];
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                                          [[self dataSource] reloadItems:[[NSArray alloc] initWithObjects:localDocument, nil]
                                                                               withItems:[[NSArray alloc] initWithObjects:localDocument, nil]];
                                                      });
                                                      
                                                      if (failure) {
                                                          dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
                                                              failure(localDocument, error);
                                                              [localDocument setUploadRequest:nil];
                                                          });
                                                      } else {
                                                          [localDocument setUploadRequest:nil];
                                                      }
                                                  } canceled:^(id<PPUploadRequestOperation> operation) {
                                                      localDocument.state = PPDocumentStateUploadFailed;
                                                      if ([[self documentUploadQueue] count] == 0) {
                                                          [self setState:PPPhotoPayCloudServiceStateReady];
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                                          if ([[[self dataSource] items] containsObject:localDocument]) {
                                                              [[self dataSource] reloadItems:[[NSArray alloc] initWithObjects:localDocument, nil]
                                                                                   withItems:[[NSArray alloc] initWithObjects:localDocument, nil]];
                                                          }
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
    BOOL saveSuccessful = [[self documentUploadQueue] insert:[localDocument copy]];
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
    
    [self setState:PPPhotoPayCloudServiceStateUploading];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
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
    
    if (delegate == nil) {
        delegate = [self uploadDelegate];
    }
    
    if ([document state] == PPDocumentStateCreated) {
        // Save local document file do documents directory
        // document saving is done in document manager's serial dispatch queue
        // this will not block the calling queue
        [document saveUsingDocumentManager:[self documentManager]
                                   success:^(PPLocalDocument*localDocument) {
                            
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
    if ([self isServiceUnavailable]) {
        return;
    }
    
    for (int i = [[self documentUploadQueue] count] - 1; i >= 0 ; i--) {
        PPLocalDocument *localDocument = [[[self documentUploadQueue] elements] objectAtIndex:i];
        [self deleteDocument:localDocument error:error];
    }
    [self setState:PPPhotoPayCloudServiceStateReady];
}

- (void)deleteDocument:(PPDocument*)document
                 error:(NSError**)error {
    if ([self isServiceUnavailable]) {
        return;
    }
    
    PPLocalDocument* localDocument = [document localDocument];
    if (localDocument != nil) {
        [[self documentManager] deleteDocument:localDocument error:error];
        [[self documentUploadQueue] remove:localDocument];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[self dataSource] removeItems:[[NSArray alloc] initWithObjects:document, nil]];
        });
        [[localDocument uploadRequest] cancel];
    } else {
        PPRemoteDocument* remoteDocument = [document remoteDocument];
        [self deleteRemoteDocument:remoteDocument
                        withSuccess:^{
                            dispatch_async(dispatch_get_main_queue(), ^() {
                                [[self dataSource] removeItems:[[NSArray alloc] initWithObjects:document, nil]];
                            });
                        } failure:^(NSError *error) {
                            ;
                        } canceled:^{
                            ;
                        }];
    }
}

- (void)deleteRemoteDocument:(PPRemoteDocument*)remoteDocument
                 withSuccess:(void (^)())success
                     failure:(void (^)(NSError* error))failure
                    canceled:(void (^)())canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* deleteDocumentOperation =
        [[self networkManager] createDeleteDocumentRequest:remoteDocument
                                                      user:[self user]
                                                   success:^(NSOperation *operation, PPBaseResponse *response) {
                                                       if (success) {
                                                           success();
                                                       }
                                                   } failure:^(NSOperation *operation, PPBaseResponse *response, NSError *error) {
                                                       if (failure) {
                                                           failure(error);
                                                       }
                                                   } canceled:^(NSOperation *operation) {
                                                       if (canceled) {
                                                           canceled();
                                                       }
                                                   }];
    [deleteDocumentOperation start];

}

- (void)getImageForDocument:(PPRemoteDocument*)document
                  imageSize:(PPImageSize)imageSize
                imageFormat:(PPImageFormat)imageFormat
                    success:(void (^)(UIImage* image))success
                    failure:(void (^)(NSError* error))failure
                   canceled:(void (^)())canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* getImageOperation =
        [[self networkManager] createGetImageRequestForDocument:document
                                                           user:[self user]
                                                      imageSize:imageSize
                                                    imageFormat:imageFormat
                                                        success:^(NSOperation *operation, UIImage *image) {
                                                            if (success) {
                                                                success(image);
                                                            }
                                                        } failure:^(NSOperation *operation, NSError *error) {
                                                            if (failure) {
                                                                failure(error);
                                                            }
                                                        } canceled:^(NSOperation *operation) {
                                                            if (canceled) {
                                                                canceled();
                                                            }
                                                        }];
    
    // add it to the operation queue
    [[[self networkManager] imagesOperationQueue] addOperation:getImageOperation];
}

- (void)getDocumentData:(PPRemoteDocument*)document
                success:(void (^)(NSData* data))success
                failure:(void (^)(NSError* error))failure
               canceled:(void (^)())canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* getDataOperation = [[self networkManager] createGetDocumentData:document
                                                                            user:[self user]
                                                                         success:^(NSOperation *operation, NSData *data) {
                                                                             if (success) {
                                                                                 success(data);
                                                                             }
                                                                         } failure:^(NSOperation *operation, NSError *error) {
                                                                             if (failure) {
                                                                                 failure(error);
                                                                             }
                                                                         } canceled:^(NSOperation *operation) {
                                                                             if (canceled) {
                                                                                 canceled();
                                                                             }
                                                                         }];
    
    // add it to the operation queue
    [[[self networkManager] documentDataOperationQueue] cancelAllOperations];
    [[[self networkManager] documentDataOperationQueue] addOperation:getDataOperation];
}

- (void)requestDocuments:(PPDocumentState)documentStates {
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSLog(@"The behaviour of this method changed. It now performs only one document fetch request");
    NSLog(@"To get the same behaviour as before, call requestDocuments:pollInterval with poll interval 5.0");
    
    [[[self networkManager] fetchDocumentsOperationQueue] cancelAllOperations];
    
    if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudServiceDidStartFetchingDocuments:)]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[self documentsFetchDelegate] cloudServiceDidStartFetchingDocuments:self];
        });
    }
    
    [self requestDocuments:documentStates
                   success:^(NSArray *documents) {
                       if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudService:didFinishFetchingWithDocuments:)]) {
                           dispatch_async(dispatch_get_main_queue(), ^(){
                               [[self documentsFetchDelegate] cloudService:self
                                            didFinishFetchingWithDocuments:documents];
                           });
                       }
                   } failure:^(NSError *error) {
                       if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudService:didFailedFetchingWithError:)]) {
                           dispatch_async(dispatch_get_main_queue(), ^(){
                               [[self documentsFetchDelegate] cloudService:self
                                                didFailedFetchingWithError:error];
                           });
                       }
                   } canceled:^{
                       if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudServiceDidCancelFetchingDocuments:)]) {
                           dispatch_async(dispatch_get_main_queue(), ^(){
                               [[self documentsFetchDelegate] cloudServiceDidCancelFetchingDocuments:self];
                           });
                       }
                   }];
}

- (void)requestDocuments:(PPDocumentState)documentStates
            pollInterval:(NSTimeInterval)timeInterval {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    NSBlockOperation * __weak _blockOperation = blockOperation;
    [blockOperation addExecutionBlock:^{
        sleep(timeInterval);
        if (![_blockOperation isCancelled]) {
            [self requestDocuments:documentStates
                      pollInterval:timeInterval];
        }
    }];
    
    [[[self networkManager] fetchDocumentsOperationQueue] cancelAllOperations];
    
    if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudServiceDidStartFetchingDocuments:)]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[self documentsFetchDelegate] cloudServiceDidStartFetchingDocuments:self];
        });
    }
    
    [self requestDocuments:documentStates
                   success:^(NSArray *documents) {
                       if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudService:didFinishFetchingWithDocuments:)]) {
                           dispatch_async(dispatch_get_main_queue(), ^(){
                               [[self documentsFetchDelegate] cloudService:self
                                            didFinishFetchingWithDocuments:documents];
                           });
                       }
                       
                       if ([[self dataSource] delegate] != nil) {
                           [[[self networkManager] fetchDocumentsOperationQueue] addOperation:blockOperation];
                       }
                   } failure:^(NSError *error) {
                       if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudService:didFailedFetchingWithError:)]) {
                           dispatch_async(dispatch_get_main_queue(), ^(){
                               [[self documentsFetchDelegate] cloudService:self
                                                didFailedFetchingWithError:error];
                           });
                       }
                       
                       if ([[self dataSource] delegate] != nil) {
                           [[[self networkManager] fetchDocumentsOperationQueue] addOperation:blockOperation];
                       }
                   } canceled:^{
                       if ([[self documentsFetchDelegate] respondsToSelector:@selector(cloudServiceDidCancelFetchingDocuments:)]) {
                           dispatch_async(dispatch_get_main_queue(), ^(){
                               [[self documentsFetchDelegate] cloudServiceDidCancelFetchingDocuments:self];
                           });
                       }
                   }];
}

- (void)requestDocuments:(PPDocumentState)documentStates
                 success:(void (^)(NSArray* documents))success
                 failure:(void (^)(NSError* error))failure
                canceled:(void (^)())canceled {
    
    self.dataSource.documentStates = documentStates;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        // remove all documents from the data source which are not in allowed states
        [self.dataSource removeItemsWithUnallowedStates];
    });
    
    static PPDocumentState lastDocumentStates = PPDocumentStateUnknown;
    
    if (documentStates != lastDocumentStates) {
        
        // document states are not the same as last presented, so recheck all existing documents in the documentUploadQueue
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            // add all documents currently in document upload queue which are in the state given by document states
            [[self dataSource] insertItems:[[NSArray alloc] initWithArray:[[self documentUploadQueue] elements] copyItems:YES]];
        });
    }
    
    [[[self networkManager] fetchDocumentsOperationQueue] addOperationWithBlock:^{
        [self requestRemoteDocuments:documentStates
                             success:success
                             failure:failure
                            canceled:canceled];
    }];
}

- (void)requestRemoteDocuments:(PPDocumentState)documentStates
                       success:(void (^)(NSArray* documents))success
                       failure:(void (^)(NSError* error))failure
                      canceled:(void (^)())canceled {
    
    [self getRemoteDocuments:documentStates
                     success:^(NSArray *remoteDocuments) {
                         
        dispatch_async(dispatch_get_main_queue(), ^() {
            // insert/reload all documents
            if ([remoteDocuments count]) {
                [[self dataSource] insertItems:remoteDocuments];
            }
            
            if (success) {
                success([[self dataSource] items]);
            }
        });
                         
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } canceled:^{
        if (canceled) {
            canceled();
        }
    }];
}

- (NSArray*)getStatesArrayForDocumentStates:(PPDocumentState)documentStateList {
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    if (documentStateList & PPDocumentStateDeleted) {
        [res addObject:@"USER_DELETED"];
    }
    if (documentStateList & PPDocumentStateReceived) {
        [res addObject:@"NEW"];
    }
    if (documentStateList & PPDocumentStatePending) {
        [res addObject:@"PENDING"];
    }
    if (documentStateList & PPDocumentStateProcessing) {
        [res addObject:@"WIP"];
    }
    if (documentStateList & PPDocumentStateProcessed) {
        [res addObject:@"DONE"];
    }
    if (documentStateList & PPDocumentStateProcessingError) {
        [res addObject:@"ERROR"];
    }
    if (documentStateList & PPDocumentStateProcessedWithError) {
        [res addObject:@"FORCED_ERROR"];
    }
    if (documentStateList & PPDocumentStatePaid) {
        [res addObject:@"RESULTS_ACK"];
    }
    
    return res;
}

- (void)getRemoteDocuments:(PPDocumentState)documentStateList
                   success:(void (^)(NSArray* remoteDocuments))success
                   failure:(void (^)(NSError* error))failure
                  canceled:(void (^)())canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSArray* states = [self getStatesArrayForDocumentStates:documentStateList];
    
    NSOperation* getDocumentsOperation =
        [[self networkManager] createGetDocumentsRequestForUser:[self user]
                                                 documentStates:states
                                                      startDate:nil
                                                        endDate:nil
                                                startsWithIndex:[NSNumber numberWithLong:0]
                                                  endsWithIndex:[NSNumber numberWithLong:1234567]
                                                        success:^(NSOperation *operation, PPBaseResponse *response) {
                                                            if (success) {
                                                                success([response documentsList]);
                                                            }
                                                        } failure:^(NSOperation *operation, PPBaseResponse *response, NSError *error) {
                                                            if (failure) {
                                                                failure(error);
                                                            }
                                                        } canceled:^(NSOperation *operation) {
                                                            if (canceled) {
                                                                canceled();
                                                            }
                                                        }];
    
    [[[self networkManager] fetchDocumentsOperationQueue] addOperation:getDocumentsOperation];
}

- (void)confirmValues:(PPUserConfirmedValues*)values
          forDocument:(PPRemoteDocument*)document
              success:(void (^)(void))success
              failure:(void (^)(NSError* error))failure
             canceled:(void (^)(void))canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* confirmValuesOperation =
        [[self networkManager] createConfirmValuesRequest:values
                                                 document:document
                                                     user:[self user]
                                                  success:^(NSOperation *operation, PPBaseResponse *response) {
                                                      dispatch_async(dispatch_get_main_queue(), ^() {
                                                          [document setState:PPDocumentStatePaid];
                                                          [[self dataSource] reloadItems:[[NSArray alloc] initWithObjects:document, nil]
                                                                               withItems:[[NSArray alloc] initWithObjects:document, nil]];
                                                          [[document delegate] documentDidChangeState:document];
                                                      });

                                                      if (success) {
                                                          success();
                                                      }
                                                  } failure:^(NSOperation *operation, PPBaseResponse *response, NSError *error) {
                                                      if (failure) {
                                                          failure(error);
                                                      }
                                                  } canceled:^(NSOperation *operation) {
                                                      if (canceled) {
                                                          canceled();
                                                      };
                                                  }];
    
    [confirmValuesOperation start];
}

- (void)registerPushNotificationToken:(NSString*)token {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* registerPushOperation =
        [[self networkManager] createRegisterPushNotificationToken:token
                                                           forUser:[self user]
                                                           success:^(NSOperation *operation, PPBaseResponse *response) {
                                                           } failure:^(NSOperation *operation, PPBaseResponse *response, NSError *error) {
                                                                                                                              NSLog(@"Registration failed");
                                                               ;
                                                           } canceled:^(NSOperation *operation) {
                                                                                                                              NSLog(@"Registration canceled");
                                                               ;
                                                           }];
    [registerPushOperation start];
}

- (void)registerUser:(PPUser*)registeredUser
             success:(void (^)(void))success
             failure:(void (^)(NSError* error))failure
            canceled:(void (^)(void))canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* registerUserRequestOperation = [[self networkManager] createRegisterUserRequest:registeredUser
                                                                                         success:^(NSOperation *operation, PPBaseResponse *response) {
                                                                                             [self registerPushNotification];
                                                                                             if (success) {
                                                                                                 success();
                                                                                             }
                                                                                         }
                                                                                         failure:^(NSOperation *operation, PPBaseResponse *response, NSError *error) {
                                                                                             NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
                                                                                             NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [response errorMessage]};                                                                                             NSError *detailedError = [[NSError alloc] initWithDomain:domain
                                                                                                                                                 code:[response errorCode]
                                                                                                                                             userInfo:userInfo];
                                                                                             if (failure) {
                                                                                                 failure(detailedError);
                                                                                             }
                                                                                         } canceled:^(NSOperation *operation) {
                                                                                             if (canceled) {
                                                                                                 canceled();
                                                                                             }
                                                                                         }];
    [registerUserRequestOperation start];
}

- (void)updateUser:(PPUser*)updatedUser
           success:(void (^)(void))success
           failure:(void (^)(NSError* error))failure
          canceled:(void (^)(void))canceled {
    
    if ([self isServiceUnavailable]) {
        return;
    }
    
    NSOperation* updateUserRequestOperation = [[self networkManager] createUpdateUserRequest:updatedUser
                                                                                     success:^(NSOperation *operation, PPBaseResponse *response) {
                                                                                         [self registerPushNotification];
                                                                                         if (success) {
                                                                                             success();
                                                                                         }
                                                                                     }
                                                                                     failure:^(NSOperation *operation, PPBaseResponse *response, NSError *error) {
                                                                                         if ([response errorMessage] != nil) {
                                                                                             NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
                                                                                             NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [response errorMessage]};                                                                                             NSError *detailedError = [[NSError alloc] initWithDomain:domain
                                                                                                                                                                                                                                                                                                                          code:[response errorCode]
                                                                                                                                                                                                                                                                                                                      userInfo:userInfo];
                                                                                             if (failure) {
                                                                                                 failure(detailedError);
                                                                                             }
                                                                                         } else {
                                                                                             if (failure) {
                                                                                                 failure(error);
                                                                                             }
                                                                                         }
                                                                                     } canceled:^(NSOperation *operation) {
                                                                                         if (canceled) {
                                                                                             canceled();
                                                                                         }
                                                                                     }];
    [updateUserRequestOperation start];
}

@end
