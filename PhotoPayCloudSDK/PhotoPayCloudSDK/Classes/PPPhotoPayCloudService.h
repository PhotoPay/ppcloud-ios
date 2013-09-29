//
//  PPPhotoPayCloudService.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/8/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPDocument.h"
#import "PPNetworkManager.h"

@protocol PPDocumentUploadDelegate;
@protocol PPUploadRequestOperation;
@class PPLocalDocument;
@class PPRemoteDocument;
@class PPUser;
@class PPDocumentManager;
@class PPDocumentsTableDataSource;
@class PPUserConfirmedValues;

/**
 States the service can be in.
 */
typedef NS_ENUM(NSUInteger, PPPhotoPayCloudServiceState) {
    
    /** 
     When created and without two objects necessary for using PhotoPayCloud, PPUser and PPNetworkManager
     the state will be PPPhotoPayCloudServiceStateUninitialized.
     */
    PPPhotoPayCloudServiceStateUninitialized,
    
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
 Performs initialization of PhotoPayCloudService object
 
 Must specify current user of the PhotoPayCloud.
 
 Also, must specify Network manager used
 */
- (void)initializeForUser:(PPUser*)user
       withNetworkManager:(PPNetworkManager*)networkManager;

/**
 Uninitializes and releases objects in PhotoPayCloudService
 
 When uninitialized, PPPhotoPayCloudService cannot make any requests towards PhotoPayCloud web api
 */
- (void)uninitialize;

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
@property (nonatomic, strong, readonly) PPNetworkManager* networkManager;

/** 
 Object responsible for managing document saving.
 
 Default implementation saves documents to application documents directory. 
 This can be overriden by custom implementation.
 */
@property (nonatomic, strong, readonly) PPDocumentManager* documentManager;

/**
 Current user of the PhotoPay Cloud web service
 
 Contains personal information which need to be sent with every web API request.
 
 Should be set before any operations. 
 It's best to set the user in your AppDelegate applicationDidBecomeActive: method to ensure
 user will always be set.
 */
@property (nonatomic, strong, readonly) PPUser* user;

/**
 Device token used for sending push notifications about processing updates to this device.
 
 Needs to be set for push notifications to work.
 
 If you don't want push notifications, set this to nil
 */
@property (nonatomic, strong) NSData* deviceToken;

/** Upload delegate for all upload requests currently in queue */
@property (nonatomic, weak) id<PPDocumentUploadDelegate> uploadDelegate;

/** Data source object for any uitableviews in charge of displaying documents */
@property (nonatomic, strong) PPDocumentsTableDataSource* dataSource;

/**
 Creating upload request for a specified document.
 
 User for which the request is created must be specified. (@see property user)
 
 Also, to use push notification, Device token must be specified.
 
 It's guaranteed that document created with this upload request will automatically be visible in
 the list of current documents (documents property).
 */
- (void)uploadDocument:(PPLocalDocument*)document
              delegate:(id<PPDocumentUploadDelegate>)delegate
               success:(void (^)(PPLocalDocument* localDocument, PPRemoteDocument* remoteDocument))success
               failure:(void (^)(PPLocalDocument* localDocument, NSError* error))failure
              canceled:(void (^)(PPLocalDocument* localDocument))canceled;

/**
 In case there were some documents which failed to upload in the last usage session for the current user,
 this method starts the upload process once more
 */
- (void)uploadPendingDocuments;

/**
 In case there were some documents which failed to upload in the last usage session for the current user,
 this method deletes all those documents.
 */
- (void)deletePendingDocumentsWithError:(NSError**)error;

/**
 Retrieves the image for a given document. The size and format of the image can be specified.
 
 Image is typically used for UI stuff, tables, etc.
 */
- (void)getImageForDocument:(PPRemoteDocument*)document
                  imageSize:(PPImageSize)imageSize
                imageFormat:(PPImageFormat)imageFormat
                    success:(void (^)(UIImage* image))success
                    failure:(void (^)(NSError* error))failure
                   canceled:(void (^)())canceled;

/**
 Retrieves the data of the document
 
 This is typically used to give the user a preview of the document sent for scanning
 */
- (void)getDocumentData:(PPRemoteDocument*)document
                success:(void (^)(NSData* data))success
                failure:(void (^)(NSError* error))failure
               canceled:(void (^)())canceled;

/**
 Confirms that the given values are indeed correct ones for payment of the document
 
 Important for improving the service, machine learning etc.
 */
- (void)confirmValues:(PPUserConfirmedValues*)values
           forDocument:(PPRemoteDocument*)document
               success:(void (^)(void))success
               failure:(void (^)(NSError* error))failure
              canceled:(void (^)(void))canceled;

/**
 Deletes the document.
 
 If document is local, it's deleted indefinitely and upload for this document will never start again
 
 If document is remote, it will delete document binary data as well as move document to a deleted state so that it will never again appear to the user.
 */
- (void)deleteDocument:(PPDocument*)document
                 error:(NSError**)error;

/**
 Retrieves documents with given statuses.
 
 @param documentState bitmask for all documents statuses which need
        to be retrieved. e.g. 
        documentStates = (PPDocumentStateCreated | PPDocumentStateUploading | PPDocumentStateReceived)
 
 Makes polls each 5 seconds (default)
 */
- (void)requestDocuments:(PPDocumentState)documentStateList;

/**
 Retrieves documents with given statuses.
 
 @param documentState bitmask for all documents statuses which need
 to be retrieved. e.g.
 documentStates = (PPDocumentStateCreated | PPDocumentStateUploading | PPDocumentStateReceived)
 
 Specifies the poll time
 */
- (void)requestDocuments:(PPDocumentState)documentStateList
            pollInterval:(NSTimeInterval)timeInterval;

@end


