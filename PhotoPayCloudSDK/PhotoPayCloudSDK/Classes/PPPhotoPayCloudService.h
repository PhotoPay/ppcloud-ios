//
//  PPPhotoPayCloudService.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPDocument.h"

@protocol PPUploadRequestOperation;
@class PPLocalDocument;
@class PPRemoteDocument;
@class PPUser;
@class PPUploadParametersQueue;
@class PPDocumentManager;
@class PPNetworkManager;

/**
 States the service can be in.
 */
typedef NS_ENUM(NSUInteger, PPPhotoPayCloudServiceState) {
    /** 
     When it's created, service is in Ready state. This state is active as long as no
     uploads are being performed.
     
     Service in this state is immediately ready to
     process requests for document uploads.
     */
    PPPhotoPayCloudServiceStateReady,
    
    /**
     When at least one upload is performed, the service is in the state Uploading.
     
     Service in this state currently performs document upload and any new uploads will be 
     queued for later. If multiple documents need to be uploaded, service will be in 
     this state until all documents are uploaded.
     */
    PPPhotoPayCloudServiceStateUploading,
    
    /**
     Service can be in state paused when the uploads pause, for whatever reason possible.
     
     One possible way for a service to get into this state is when the application 
     user logs out from the application, which stopps any uploads currently in progress.
     
     When your application observes that Cloud service is in state Paused, it's best to
     ask the user if he wants to continue pending uploads.
     */
    PPPhotoPayCloudServiceStatePaused,
    
    /**
     Placeholder for any possible errorenous state.
     */
    PPPhotoPayCloudServiceStateError
};

/** 
 Entry point for using PhotoPay Cloud from your custom applications.
 
 Provides methods for:
    - requesting document uploads
    - retrieving scanning results
    - requesting push notifications
    - reporting user-confirmed payment data values
    - obtaining all documents for a specified user
    - resuming paused upload requests
 */
@interface PPPhotoPayCloudService : NSObject

/**
 Obtaines shared service instance
 */
+ (PPPhotoPayCloudService*)sharedService;

/**
 The callback dispatch queue on success. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t successDispatchQueue;

/**
 The callback dispatch queue on failure or cancelation. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t failureDispatchQueue;

/**
 Specifies the state PhotoPayCloudService is in.
 */
@property (nonatomic, readonly) PPPhotoPayCloudServiceState state;

/**
 Object responsible for managing network communication
 */
@property (nonatomic, strong) PPNetworkManager* networkManager;

/** 
 Object responsible for managing document saving.
 
 Default implementation saves documents to application documents directory. 
 This can be overriden by custom implementation.
 */
@property (nonatomic, strong) PPDocumentManager* documentManager;

/**
 Current user of the PhotoPay Cloud web service
 
 Contains personal information which need to be sent with every web API request.
 
 Should be set before any operations. 
 It's best to set the user in your AppDelegate applicationDidBecomeActive: method to ensure
 user will always be set.
 */
@property (nonatomic, strong) PPUser* user;

/**
 Device token used for sending push notifications about processing updates to this device.
 
 Needs to be set for push notifications to work.
 */
@property (nonatomic, strong) NSData* deviceToken;

/**
 Creating upload request for a specified document.
 
 User for which the request is created must be specified. (@see property user)
 
 Also, to use push notification, Device token must be specified.
 
 It's guaranteed that document created with this upload request will automatically be visible in
 the list of current documents (documents property).
 */
- (void)uploadDocument:(PPLocalDocument*)document
            pushNotify:(BOOL)pushNotify
               success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
               failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
              canceled:(void (^)(PPLocalDocument* localDocument))canceled;

/**
 Retrieves documents with given statuses.
 
 @param documentState bitmask for all documents statuses which need
        to be retrieved. e.g. 
        documentStates = (PPDocumentStateCreated | PPDocumentStateUploading | PPDocumentStateReceived)
 */
- (void)getDocuments:(PPDocumentState)documentStates
             success:(void (^)(NSArray* documents))success
             failure:(void (^)(NSError* error))failure
            canceled:(void (^)(void))canceled;

@end
