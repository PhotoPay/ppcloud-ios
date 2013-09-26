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
 Operation queue which handles for all documents in home view
 */
@property (nonatomic, strong) NSOperationQueue* fetchDocumentsOperationQueue;

@end

@implementation PPNetworkManager

@synthesize uploadDelegate;
@synthesize uploadOperationQueue;
@synthesize imagesOperationQueue;
@synthesize fetchDocumentsOperationQueue;

- (id)init {
    self = [super init];
    if (self) {
        uploadOperationQueue = [[NSOperationQueue alloc] init];
        uploadOperationQueue.name = @"PhotoPay Cloud Upload Queue";
        [uploadOperationQueue setMaxConcurrentOperationCount:2];
        
        imagesOperationQueue = [[NSOperationQueue alloc] init];
        imagesOperationQueue.name = @"PhotoPay Cloud Images Queue";
        [imagesOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        
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

@end
