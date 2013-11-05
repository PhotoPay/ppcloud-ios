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
#import "PPBaseResponse.h"
#import "PPNetworkUtils.h"
#import "PPDocument.h"
#import "PPUser.h"

NSString* const kPPParameterData = @"data";
NSString* const kPPParameterCustomerId = @"customerId";
NSString* const kPPParameterOrganizationId = @"organizationId";
NSString* const kPPParameterRequestType = @"requestType";
NSString* const kPPParameterFileType = @"fileType";
NSString* const kPPParameterDeviceToken = @"deviceToken";
NSString* const kPPParameterPushNotify = @"pushNotify";
NSString* const kPPParameterCustomerType = @"customerType";
NSString* const kPPParameterStartDate = @"startDate";
NSString* const kPPParameterEndDate = @"endDate";
NSString* const kPPParameterStartsWith = @"startWith";
NSString* const kPPParameterPerPage = @"perPage";
NSString* const kPPParameterHeight = @"heightSize";
NSString* const kPPParameterImageFormat = @"imageFormat";
NSString* const kPPParameterStatus = @"status";

@interface PPNetworkManager ()

/**
 Operation queue which handles upload requests
 */
@property (nonatomic, strong) NSOperationQueue* uploadOperationQueue;

/**
 Operation queue which handles requests for images (thumbnails, etc.)
 */
@property (nonatomic, strong) NSOperationQueue* imagesOperationQueue;

/**
 Operation queue which handles requests for document data
 */
@property (nonatomic, strong) NSOperationQueue* documentDataOperationQueue;

/**
 Operation queue which handles for all documents in home view
 */
@property (nonatomic, strong) NSOperationQueue* fetchDocumentsOperationQueue;

@end

@implementation PPNetworkManager

@synthesize uploadDelegate;
@synthesize uploadOperationQueue;
@synthesize documentDataOperationQueue;
@synthesize imagesOperationQueue;
@synthesize fetchDocumentsOperationQueue;

- (id)init {
    self = [super init];
    if (self) {
        uploadOperationQueue = [[NSOperationQueue alloc] init];
        uploadOperationQueue.name = @"PhotoPay Cloud Upload Queue";
        [uploadOperationQueue setMaxConcurrentOperationCount:1];
        
        imagesOperationQueue = [[NSOperationQueue alloc] init];
        imagesOperationQueue.name = @"PhotoPay Cloud Images Queue";
        [imagesOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        
        documentDataOperationQueue = [[NSOperationQueue alloc] init];
        documentDataOperationQueue.name = @"PhotoPay Cloud Document Data Queue";
        [documentDataOperationQueue setMaxConcurrentOperationCount:1];
        
        fetchDocumentsOperationQueue = [[NSOperationQueue alloc] init];
        fetchDocumentsOperationQueue.name = @"PhotoPay Cloud Fetch Documents Queue";
        [fetchDocumentsOperationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (id)httpClient {
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

+ (NSDictionary*)imageFormatObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPImageFormatJpeg) : @"JPEG",
                  @(PPImageFormatPng) : @"PNG"};
    });
    return table;
}

+ (NSDictionary *)imageSizeObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPImageSizeThumbnailMdpi) : @"THUMBNAIL_MDPI",
                  @(PPImageSizeThumbnailHdpi) : @"THUMBNAIL_HDPI",
                  @(PPImageSizeThumbnailXHdpi) : @"THUMBNAIL_XHDPI",
                  @(PPImageSizeThumbnailXXHdpi) : @"THUMBNAIL_XXHDPI",
                  @(PPImageSizeUIMdpi) : @"UI_MDPI",
                  @(PPImageSizeUIHdpi) : @"UI_HDPI",
                  @(PPImageSizeUIXHdpi) : @"UI_XHDPI",
                  @(PPImageSizeUIXXHdpi) : @"UI_XXHDPI",
                  @(PPImageSizeFull) : @"FULL_IMAGE"};
    });
    return table;
}

+ (id)objectForImageFormat:(PPImageFormat)imageFormat {
    return [PPNetworkManager imageFormatObjectTable][@(imageFormat)];
}

+ (id)objectForImageSize:(PPImageSize)imageSize {
     return [PPNetworkManager imageSizeObjectTable][@(imageSize)];
}

+ (NSString*)apiPathUpload {
    return @"cloud/upload/document/";
}

+ (NSString*)apiPathStatusForDocument:(PPDocument*)document {
    NSString *documentId = [PPNetworkUtils percentEscapedStringKeyFromString:[document documentId]
                                                                withEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"cloud/document/%@/status", documentId];
}

+ (NSString*)apiPathDataForDocument:(PPDocument*)document {
    NSString *documentId = [PPNetworkUtils percentEscapedStringKeyFromString:[document documentId]
                                                                withEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"cloud/document/%@/data", documentId];
}

+ (NSString*)apiPathDocumentsForUser:(PPUser*)user {
    NSString *userId = [PPNetworkUtils percentEscapedStringKeyFromString:[user userId]
                                                            withEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"cloud/customer/documents/%@", userId];
}

+ (NSString*)apiPathImageForDocument:(PPDocument*)document {
    NSString *documentId = [PPNetworkUtils percentEscapedStringKeyFromString:[document documentId]
                                                                withEncoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"cloud/image/%@", documentId];
}

+ (NSString*)apiPathConfirmDataForDocument:(PPDocument*)document {
    NSString *documentId = [PPNetworkUtils percentEscapedStringKeyFromString:[document documentId]
                                                                withEncoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"cloud/payment/%@", documentId];
}

+ (NSString*)apiPathPushRegistrationForUser:(PPUser*)user {
    NSString *userId = [PPNetworkUtils percentEscapedStringKeyFromString:[user userId]
                                                            withEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"cloud/customer/pushNotificationRegistration/%@", userId];
}

+ (NSString*)apiPathDeleteDocument:(PPDocument*)document {
    NSString *documentId = [PPNetworkUtils percentEscapedStringKeyFromString:[document documentId]
                                                                withEncoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"cloud/delete/%@", documentId];
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

- (NSOperation*)createGetDocumentsRequestForUser:(PPUser *)user
                                  documentStates:(NSArray*)documentStates
                                       startDate:(NSDate*)startDate
                                         endDate:(NSDate*)endDate
                                 startsWithIndex:(NSNumber*)startsWith
                                   endsWithIndex:(NSNumber*)endsWith
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSArray *))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                        canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSOperation*)createGetImageRequestForDocument:(PPRemoteDocument*)remoteDocument
                                            user:(PPUser *)user
                                       imageSize:(PPImageSize)imageSize
                                     imageFormat:(PPImageFormat)imageFormat
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                        canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSOperation*)createGetDocumentData:(PPRemoteDocument*)remoteDocument
                                 user:(PPUser *)user
                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *image))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                             canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSOperation*)createDeleteDocumentRequest:(PPRemoteDocument*)remoteDocument
                                       user:(PPUser *)user
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, PPBaseResponse *baseResponse))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                   canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSOperation*)createConfirmValuesRequest:(PPUserConfirmedValues*)values
                                  document:(PPRemoteDocument*)remoteDocument
                                      user:(PPUser *)user
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, PPBaseResponse *baseResonse))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                  canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSOperation*)createRegisterPushNotificationToken:(NSString*)token
                                            forUser:(PPUser *)user
                                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, PPBaseResponse *baseResonse))success
                                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                           canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // this method must be overriden by the application
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

@end
