//
//  PPNetworkManager.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PPUploadRequestOperation.h"

@class PPLocalDocument;
@class PPRemoteDocument;
@class PPUser;

/** Parameter names of all API methods in PhotoPay Cloud */

/** data parameter that contains raw document data on upload */
extern NSString* const kPPParameterData;

/** parameter that contains customerId/clientId */
extern NSString* const kPPParameterCustomerId;

/** parameter that contains organizationId */
extern NSString* const kPPParameterOrganizationId;

/**
 * parameter that defines request type on upload (what kind of document
 * processing is required)
 */
extern NSString* const kPPParameterRequestType;

/** parameter that defines the type of file being uploaded */
extern NSString* const kPPParameterFileType;

/**
 * parameter that defines token of the device used for sending push
 * notifications
 */
extern NSString* const kPPParameterDeviceToken;

/**
 * parameter that defines whether device wants to receive push
 * notification when document that is being uploaded finished processing
 */
extern NSString* const kPPParameterPushNotify;

/** parameter that defines the type of the customer/client */
extern NSString* const kPPParameterCustomerType;

/**
 * parameter that defines the start date when fetching document list -
 * no documents older than startDate will be returned
 */
extern NSString* const kPPParameterStartDate;

/**
 * parameter that defines the end date when fetching document list - no
 * documents newer than endDate will be returned
 */
extern NSString* const kPPParameterEndDate;

/**
 * parameter that defines index of document that will be first in the
 * list of returned documents
 */
extern NSString* const kPPParameterStartsWith;

/**
 * parameter that defines how many documents will be returned per
 * request
 */
extern NSString* const kPPParameterPerPage;

/** parameter that defines the height of the desired image size */
extern NSString* const kPPParameterHeight;

/** parameter that defines the format of the desired resized image */
extern NSString* const kPPParameterImageFormat;

/**
 * parameter that defines status of document that is allowed to be
 * fetched
 */
extern NSString* const kPPParameterStatus;

typedef NS_ENUM(NSUInteger, PPImageSize) {
    /** Thumbnail size on MDPI devices */
    PPImageSizeThumbnailMdpi,
    /** Thumbnail size on HDPI devices */
    PPImageSizeThumbnailHdpi,
    /** Thumbnail size on XHDPI devices */
    PPImageSizeThumbnailXHdpi,
    /** Thumbnail size on XXHDPI devices */
    PPImageSizeThumbnailXXHdpi,
    /** UI image size on MDPI devices */
    PPImageSizeUIMdpi,
    /** UI image size on HDPI devices */
    PPImageSizeUIHdpi,
    /** UI image size on XHDPI devices */
    PPImageSizeUIXHdpi,
    /** UI image size on XXHDPI devices */
    PPImageSizeUIXXHdpi,
    /** Full image */
    PPImageSizeFull
};

typedef NS_ENUM(NSUInteger, PPImageFormat) {
    /** JPEG format */
    PPImageFormatJpeg,
    /** PNG format */
    PPImageFormatPng
};

@interface PPNetworkManager : NSObject

/**
 Operation queue which handles upload requests
 */
@property (nonatomic, strong, readonly) NSOperationQueue* uploadOperationQueue;

/**
 Operation queue which handles requests for images (thumbnails, etc.)
 */
@property (nonatomic, strong, readonly) NSOperationQueue* imagesOperationQueue;

/**
 Operation queue which handles for all documents in home view
 */
@property (nonatomic, strong, readonly) NSOperationQueue* fetchDocumentsOperationQueue;

/** Upload delegate for all upload requests currently in queue */
@property (nonatomic, weak) id<PPDocumentUploadDelegate> uploadDelegate;

/**
 Creates and returns an map enum value : object value for enum PPImageFormat
 
 This is primarily used in making network requests
 */
+ (NSDictionary*)imageFormatObjectTable;

/**
 Creates and returns an map enum value : object value for enum PPImageSize
 
 This is primarily used in making network requests
 */
+ (NSDictionary *)imageSizeObjectTable;

/**
 Returns object representation of PPImageFormat enum value
 */
+ (id)objectForImageFormat:(PPImageFormat)imageFormat;

/**
 Returns object representation for the PPImageSize enum
 */
+ (id)objectForImageSize:(PPImageSize)imageSize;

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

/**
 Abstract.
 Factory method for creating request operation for obtaining all documents of a particular user
 
 Should be implemented by the application
 */
- (NSOperation*)createGetDocumentsRequestForUser:(PPUser *)user
                                  documentStates:(NSArray*)documentStates
                                       startDate:(NSDate*)startDate
                                         endDate:(NSDate*)endDate
                                 startsWithIndex:(NSNumber*)startsWith
                                   endsWithIndex:(NSNumber*)endsWith
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSArray *))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                        canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled;

/**
 Abstract.
 Factory method for creating request operations for obtaining image for a given document belonging to a user.
 
 Should be implemented by the application
 */
- (NSOperation*)createGetImageRequestForDocument:(PPRemoteDocument*)remoteDocument
                                            user:(PPUser *)user
                                       imageSize:(PPImageSize)imageSize
                                     imageFormat:(PPImageFormat)imageFormat
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                        canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled;

/**
 Abstract.
 Factory method for creating request operations for obtaining document data. Document data represent the actual document sent to PhotoPayCloud service for recognition.
 
 Should be implemented by the application
 */
- (NSOperation*)createGetDocumentData:(PPRemoteDocument*)remoteDocument
                                 user:(PPUser *)user
                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *image))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                             canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled;



@end
