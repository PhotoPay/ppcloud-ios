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
#import "PPUploadParameters.h"
#import "PPDocumentManager.h"
#import "NSString+Factory.h"
#import "PPUploadParametersQueue.h"
#import "PPNetworkManager.h"

/** Private extensions to PhotoPayCloud Service */
@interface PPPhotoPayCloudService ()

/**
 This queue contains a list of UploadParameters objects. These represent all LocalDocuments which are
 still uploading and not yet sent to the PhotoPay Cloud web application.
 */
@property (nonatomic, strong) PPUploadParametersQueue* uploadParametersQueue;

/** Serial dispatch queue for upload requests */
@property (nonatomic, assign) dispatch_queue_t uploadDispatchQueue;

/** Override of the state property. Inside of the class it's changeable */
@property (nonatomic) PPPhotoPayCloudServiceState state;

/**
 Helper method for creating Upload parameters object
 */
- (PPUploadParameters*)createUploadParameters:(PPLocalDocument*)document
                                   pushNotify:(BOOL)pushNotify;

@end

@implementation PPPhotoPayCloudService

@synthesize user;
@synthesize state;
@synthesize documentManager;
@synthesize networkManager;
@synthesize uploadDispatchQueue;
@synthesize successDispatchQueue;
@synthesize failureDispatchQueue;
@synthesize uploadParametersQueue;

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
        uploadParametersQueue = [[PPUploadParametersQueue alloc] init];
        
        // uploading is ready
        state = PPPhotoPayCloudServiceStateReady;
        
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
    
    // deserialize the request queue for this user
    NSString* userIdHash = [[[self user] userId] MD5];
    uploadParametersQueue = [PPUploadParametersQueue queueForUserIdHash:userIdHash];
    
    if (uploadParametersQueue == nil) {
        // we don't have any existing uploads
        uploadParametersQueue = [[PPUploadParametersQueue alloc] init];
        self.state = PPPhotoPayCloudServiceStateReady;
    } else {
        self.state = PPPhotoPayCloudServiceStatePaused;
    }
}

- (void)uploadDocument:(PPLocalDocument*)document
            pushNotify:(BOOL)pushNotify
               success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
               failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
              canceled:(void (^)(PPLocalDocument* localDocument))canceled {
    
    if (document == nil) {
        NSLog(@"Cannot process request without valid document object");
        return;
    }
    
    if ([self user] == nil) {
        NSLog(@"Cannot process request without valid user object specified");
        NSLog(@"Please set the user object using user property of PPPhotoPayCloudSerice object");
        return;
    }
    
    // Save local document file do documents directory
    // document saving is done in document manager's serial dispatch queue
    // this will not block the calling queue
    [document saveUsingDocumentManager:[self documentManager]
                                 success:^(PPLocalDocument*localDocument, NSURL* documentUrl) {
                                     
                                     // success block is done again in upload dispatch queue
                                     // @see init
                                     // main queue is still free
                                     PPUploadParameters *uploadParameters = [self createUploadParameters:document
                                                                                              pushNotify:pushNotify];
                                     
                                     NSLog(@"Document is:\n%@", [localDocument toString]);
                                
                                     
                                     // create the upload request
                                     id<PPUploadRequestOperation> uploadRequest =
                                        [[self networkManager] createUploadRequestForUser:[self user]
                                                                         uploadParameters:uploadParameters
                                                                                  success:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument) {
                                                                                      [[self uploadParametersQueue] remove:uploadParameters];
                                                                                      if (success) {
                                                                                          success(document, remoteDocument);
                                                                                      }
                                                                                  }
                                                                                  failure:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument, NSError *error) {
                                                                                      [[self uploadParametersQueue] remove:uploadParameters];
                                                                                      if (failure) {
                                                                                          failure(document, error);
                                                                                      }
                                                                                  }
                                                                                 canceled:^(id<PPUploadRequestOperation> request, PPLocalDocument* localDocument) {
                                                                                     [[self uploadParametersQueue] remove:uploadParameters];
                                                                                     if (canceled) {
                                                                                         canceled(document);
                                                                                     }
                                                                                 }];
                                     
                                     // enqueue upload parameters queue;
                                     // also serializes upload parameters object to documents directory
                                     BOOL ok = [[self uploadParametersQueue] enqueue:[uploadRequest uploadParameters]];
                                     if (!ok) {
                                         NSLog(@"Failed save!");
                                         
                                         NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
                                         NSString *desc = @"PhotoPayErrorUploadCannotStoreRequest";
                                         NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
                                         NSError *error = [NSError errorWithDomain:domain
                                                                              code:2003
                                                                          userInfo:userInfo];
                                         
                                         if (failure) {
                                             failure(document, error);
                                         }
                                     }
                                     
                                     // add it to the operation queue
                                     [[[self networkManager] uploadOperationQueue] addOperation:uploadRequest];
                                     
                                     // resets the upload delegate so it also receives events about the new request
                                     [[self networkManager] setUploadDelegate:[[self networkManager] uploadDelegate]];
                                     
                                 } failure:^(PPLocalDocument*localDocument, NSError*error) {
                                     // success block is done again in upload dispatch queue
                                     // @see init
                                     // main queue is still free
                                     
                                     dispatch_async(self.failureDispatchQueue ?: dispatch_get_main_queue(), ^{
                                         failure(document, error);
                                     });
                                     
                                     NSLog(@"Error while saving document!");
                                 }];

    NSLog(@"Uploading document");
}

- (PPUploadParameters*)createUploadParameters:(PPLocalDocument*)document
                                   pushNotify:(BOOL)pushNotify {
    // create PPUploadParameters object
    PPUploadParameters* uploadParameters = [[PPUploadParameters alloc] init];
    
    // set document data
    [uploadParameters setLocalDocument:document];
    
    NSString* userIdHash = [[[self user] userId] MD5];
    
    // set user data
    [uploadParameters setUserIdHash:userIdHash];
    [uploadParameters setOrganizationId:[[self user] organizationId]];
    [uploadParameters setUserType:[[self user] userType]];
    
    // set push notification data
    [uploadParameters setPushNotify:pushNotify];
    [uploadParameters setDeviceToken:[self deviceToken]];
    
    // set creation date
    [uploadParameters setCreationDate:[NSDate date]];
    
    return uploadParameters;
}

- (void)getDocuments:(PPDocumentState)documentStates
             success:(void (^)(NSArray *))success
             failure:(void (^)(NSError *))failure
            canceled:(void (^)(void))canceled {
    
}

@end
