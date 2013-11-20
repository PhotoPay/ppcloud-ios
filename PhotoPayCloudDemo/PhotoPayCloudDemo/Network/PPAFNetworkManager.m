//
//  PPAFNetworkManager.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPAFNetworkManager.h"
#import "PPAFUploadRequestOperation.h"
#import <PhotoPayCloud/PhotoPayCloud.h>

@interface PPAFNetworkManager ()

/**
 Getter for request serializer which retrieves the object from AFHTTPRequestOperationManager
 */
@property (nonatomic, readonly) AFHTTPRequestSerializer* requestSerializer;

/**
 Base URL string to PhotoPayCloud web services
 */
@property (nonatomic, strong) NSString* baseURLString;

/**
 Prepares the request parameters for a given user.
 
 Error checking is performed.
 */
- (NSMutableDictionary*)requestParametersForUser:(PPUser*)user
                                           error:(NSError**)error;

/**
 Prepares the request parameters dictionary with user and upload data
 Also performs error checking so any errors in the request will be immediately reported,
 without the need for waiting rejection from the server
 */
- (NSDictionary*)uploadRequestParametersForUser:(PPUser*)user
                                  localDocument:(PPLocalDocument*)document
                                          error:(NSError**)error;
@end

@implementation PPAFNetworkManager

@synthesize requestOperationManager;
@synthesize baseURLString;

+ (AFHTTPRequestOperationManager*)defaultOperationManagerForBaseURLString:(NSString*)URLString {
    AFHTTPRequestOperationManager* manager =  [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:URLString]];
    
    /** Default request serializer */
    AFHTTPRequestSerializer* requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    NSString* osString = [NSString stringWithFormat:@"%@: %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    [requestSerializer setValue:osString forHTTPHeaderField:@"X-OS"];
    NSString* buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString* appVersion = [NSString stringWithFormat:@"Build: %@, Version: %@", buildNumber, versionNumber];
    [requestSerializer setValue:appVersion forHTTPHeaderField:@"X-app-version"];
    manager.requestSerializer = requestSerializer;
    
    /** Default response serializer, solves the issue with acceptableContentTypes on Erste bank server */
    AFHTTPResponseSerializer* responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableSet *acceptableContentTypes = [[responseSerializer acceptableContentTypes] mutableCopy];
    [acceptableContentTypes addObject:@"text/plain"];
    [responseSerializer setAcceptableContentTypes:acceptableContentTypes];
    manager.responseSerializer = responseSerializer;
    
    /** Default security policy, allows invalid certificates */
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
#ifdef DEBUG
    securityPolicy.allowInvalidCertificates = YES;
#endif
    manager.securityPolicy = securityPolicy;
    
    return manager;
}

/**
 Initializes network managet with a custom AFHTTPRequestOperationManager object
 */
- (id)initWithRequestOperationManager:(AFHTTPRequestOperationManager*)inRequestOperationManager {
    self = [super init];
    if (self) {
        baseURLString = [[inRequestOperationManager baseURL] absoluteString];
        requestOperationManager = inRequestOperationManager;
    }
    return self;
}

- (AFHTTPRequestSerializer*)requestSerializer {
    return [[self requestOperationManager] requestSerializer];
}

- (NSMutableDictionary*)requestParametersForUser:(PPUser*)user
                                           error:(NSError**)error {
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    
    // set user id and check for possible error
    if ([user userId] != nil && [[user userId] length] != 0) {
        [requestParams setObject:[user userId] forKey:kPPParameterCustomerId];
    } else {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadUserIdNotSet";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        if (error != nil) {
            *error = [NSError errorWithDomain:domain
                                         code:2001
                                     userInfo:userInfo];
        }
    }
    
    // set user type if specified (if not specified, server default will be used
    if ([user userType] != PPUserTypeDefault) {
        [requestParams setObject:[PPUser objectForUserType:[user userType]] forKey:kPPParameterCustomerType];
    }
    
    // set organization id if specified (if not specified, server default will be used
    if ([user organizationId] != nil && [[user organizationId] length] != 0) {
        [requestParams setObject:[user organizationId] forKey:kPPParameterOrganizationId];
    } else {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadOrganisationIdNotSet";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        if (error != nil) {
            *error = [NSError errorWithDomain:domain
                                         code:2004
                                     userInfo:userInfo];
        }
    }
    
    return requestParams;
}

- (NSDictionary*)uploadRequestParametersForUser:(PPUser*)user
                                  localDocument:(PPLocalDocument*)document
                                          error:(NSError**)error {
    NSMutableDictionary* uploadRequestParams = [self requestParametersForUser:user error:error];
    
    if (*error != nil) {
        return nil;
    }
    
    // set request type (this will always be specified)
    [uploadRequestParams setObject:[PPDocument objectForDocumentProcessingType:[document processingType]]
                            forKey:kPPParameterRequestType];
    
    // file type will also always be specified
    [uploadRequestParams setObject:[PPDocument objectForDocumentType:[document documentType]]
                            forKey:kPPParameterFileType];
    
    // file type will also always be specified
    [uploadRequestParams setObject:@(([[PPPhotoPayCloudService sharedService] deviceToken] != nil))
                            forKey:kPPParameterPushNotify];
    
    // callback URL and device token are never sent
    
    return uploadRequestParams;
}

- (id<PPUploadRequestOperation>)createUploadRequestForUser:(PPUser *)user
                                             localDocument:(PPLocalDocument*)document
                                                   success:(void (^)(id<PPUploadRequestOperation>, PPBaseResponse*))success
                                                   failure:(void (^)(id<PPUploadRequestOperation>, PPBaseResponse*, NSError *))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation>))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSDictionary *uploadRequestParameters = [self uploadRequestParametersForUser:user
                                                                   localDocument:document
                                                                           error:&error];
    if (error != nil) {
        NSLog(@"%@", [NSString stringWithFormat:@"Error creating request: %@", [error localizedDescription]]);
        failure(nil, nil, error);
        return nil;
    }
    
    // 2. create multipart request
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathUpload]];
    NSMutableURLRequest *multipartRequest =
        [[self requestSerializer] multipartFormRequestWithMethod:@"POST"
                                                       URLString:urlString
                                                      parameters:uploadRequestParameters
                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                           [formData appendPartWithFileData:[document bytes]
                                                                       name:kPPParameterData
                                                                   fileName:[[document cachedDocumentUrl] lastPathComponent]
                                                                   mimeType:[document mimeType]];
                                       }];
    
    // 3. create upload operation from multipart request
    PPAFUploadRequestOperation* uploadRequestOperation = [[PPAFUploadRequestOperation alloc] initWithRequest:multipartRequest];
    uploadRequestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    uploadRequestOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    // 4. check for errors
    if (uploadRequestOperation == nil) {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = _(@"PhotoPayErrorUploadCannotCreateRequest");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2002
                                         userInfo:userInfo];
        failure(nil, nil, error);
        
        return nil;
    }
    
    __weak PPAFUploadRequestOperation* _uploadRequestOperation = uploadRequestOperation;
    
    // 5. add upload progress block
    [uploadRequestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        _uploadRequestOperation.progress = [[NSNumber alloc] initWithDouble:totalBytesWritten / (double)totalBytesExpectedToWrite];
        
        if ([_uploadRequestOperation.delegate respondsToSelector:@selector(localDocument:didUpdateProgressWithBytesWritten:totalBytesToWrite:)]) {
            [[_uploadRequestOperation delegate] localDocument:document
                            didUpdateProgressWithBytesWritten:totalBytesWritten
                                            totalBytesToWrite:totalBytesExpectedToWrite];
        }
    }];
    
    // 6. add success, failure and cancellation blocks
    [uploadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:responseObject];
        
        if (success) {
            success(_uploadRequestOperation, baseResponse);
        }
        
        if ([_uploadRequestOperation.delegate respondsToSelector:@selector(localDocument:didFinishUploadWithResult:)]) {
            [_uploadRequestOperation.delegate localDocument:document
                              didFinishUploadWithResult:[baseResponse document]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Upload failed with response %@", operation.responseString);
        
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:operation.responseObject];
        
        if (error != nil && error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            
            NSLog(@"Canceled");
            if (canceled) {
                canceled(_uploadRequestOperation);
            }
            
            if ([_uploadRequestOperation.delegate respondsToSelector:@selector(localDocumentDidCancelUpload:)]) {
                [_uploadRequestOperation.delegate localDocumentDidCancelUpload:document];
            }
            
            return;
        } else {
            
            NSLog(@"Error! %@", error);
            if (failure) {
                failure((id<PPUploadRequestOperation>)operation, baseResponse, error);
            }
            
            if ([_uploadRequestOperation.delegate respondsToSelector:@selector(localDocument:didFailToUploadWithError:)]) {
                [_uploadRequestOperation.delegate localDocument:document
                                       didFailToUploadWithError:error];
            }
        }
    }];
    
    // 7. execute as background task
    [uploadRequestOperation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^() {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = _(@"PhotoPayErrorUploadOperationTooLong");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2005
                                         userInfo:userInfo];
        
        failure(_uploadRequestOperation, nil, error);
    }];
    
    // 7. done
    return uploadRequestOperation;
}

- (NSOperation*)createGetDocumentsRequestForUser:(PPUser *)user
                                  documentStates:(NSArray*)documentStates
                                       startDate:(NSDate*)startDate
                                         endDate:(NSDate*)endDate
                                 startsWithIndex:(NSNumber*)startsWithIndex
                                   endsWithIndex:(NSNumber*)numElements
                                         success:(void (^)(NSOperation*, PPBaseResponse*))success
                                         failure:(void (^)(NSOperation*, PPBaseResponse*, NSError *))failure
                                        canceled:(void (^)(NSOperation*))canceled {
    
    // 1. create parameters dictionary
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    
    // set user type if specified (if not specified, server default will be used
    if ([user userType] != PPUserTypeDefault) {
        [requestParams setObject:[PPUser objectForUserType:[user userType]] forKey:kPPParameterCustomerType];
    }
    
    [requestParams setObject:[user userId] forKey:kPPParameterCustomerId];
    
    // set organization id if specified (if not specified, server default will be used
    if ([user organizationId] != nil && [[user organizationId] length] != 0) {
        [requestParams setObject:[user organizationId] forKey:kPPParameterOrganizationId];
    } else {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadOrganisationIdNotSet";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2004
                                         userInfo:userInfo];
        
        if (failure) {
            failure(nil, nil, error);
        }
        return nil;
    }
    
    if (startDate != nil) {
        // set start date as number of milliseconds from 1970
        [requestParams setObject:@((long long)([startDate timeIntervalSince1970] * 1000.f))
                          forKey:kPPParameterStartDate];
    }
    
    if (endDate != nil) {
        // set end date as number of milliseconds from 1970
        // set start date as number of milliseconds from 1970
        [requestParams setObject:@((long long)([endDate timeIntervalSince1970] * 1000.f))
                          forKey:kPPParameterEndDate];
    }
    
    // set start index of documents
    [requestParams setObject:@([startsWithIndex longValue])
                      forKey:kPPParameterStartsWith];
    
    // set end index of documents
    [requestParams setObject:@([numElements longValue])
                      forKey:kPPParameterPerPage];
    
    
    NSMutableSet* states = [[NSMutableSet alloc] init];
    for (NSString* state in documentStates) {
        [states addObject:state];
    }
    
    // set end index of documents
    [requestParams setObject:states
                      forKey:kPPParameterStatus];
    
    // 2. create request
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathDocumentsForUser:user]];
    NSMutableURLRequest *getRequest = [[self requestSerializer] requestWithMethod:@"GET"
                                                                        URLString:urlString
                                                                       parameters:requestParams];
    
    AFHTTPRequestOperation *getRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:getRequest];
    getRequestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    getRequestOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    [getRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:responseObject];
        
        if (success) {
            success(operation, baseResponse);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get documents failed with response %@", operation.responseString);
        
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:operation.responseObject];
        
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            NSLog(@"Canceled");
            if (canceled) {
                canceled(operation);
            }
            return;
        }
        
        NSLog(@"Error! %@", error);
        if (failure != nil) {
            failure(operation, baseResponse, error);
        }
    }];
    
    return getRequestOperation;
}

- (NSOperation*)createGetImageRequestForDocument:(PPRemoteDocument*)remoteDocument
                                            user:(PPUser *)user
                                       imageSize:(PPImageSize)imageSize
                                     imageFormat:(PPImageFormat)imageFormat
                                         success:(void (^)(NSOperation*, UIImage*))success
                                         failure:(void (^)(NSOperation*, NSError*))failure
                                        canceled:(void (^)(NSOperation*))canceled {
    
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    // set request type (this will always be specified)
    [requestParams setObject:[PPNetworkManager objectForImageFormat:imageFormat]
                      forKey:kPPParameterImageFormat];
    
    // file type will also always be specified
    [requestParams setObject:[PPNetworkManager objectForImageSize:imageSize]
                            forKey:kPPParameterHeight];
    
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathImageForDocument:remoteDocument]];
    NSMutableURLRequest *urlRequest = [[self requestSerializer] requestWithMethod:@"GET"
                                                                        URLString:urlString
                                                                       parameters:requestParams];
        
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    requestOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get image failed with response %@", operation.responseString);
        
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            NSLog(@"Canceled");
            if (canceled) {
                canceled(operation);
            }
            return;
        }
        
        NSLog(@"Error! %@", error);
        if (failure != nil) {
            failure(operation, error);
        }
    }];

    return requestOperation;
}

- (NSOperation*)createGetDocumentData:(PPRemoteDocument*)remoteDocument
                                 user:(PPUser *)user
                              success:(void (^)(NSOperation*, NSData*))success
                              failure:(void (^)(NSOperation*, NSError*))failure
                             canceled:(void (^)(NSOperation*))canceled {
    
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathDataForDocument:remoteDocument]];
    NSMutableURLRequest *urlRequest = [[self requestSerializer] requestWithMethod:@"GET"
                                                                        URLString:urlString
                                                                       parameters:requestParams];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, operation.responseData);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get document data failed with response %@", operation.responseString);
        
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            NSLog(@"Canceled");
            if (canceled) {
                canceled(operation);
            }
            return;
        }
        
        NSLog(@"Fail! %@", error);
        if (failure != nil) {
            failure(operation, error);
        }
    }];
    
    return requestOperation;
}

- (NSOperation*)createDeleteDocumentRequest:(PPRemoteDocument*)remoteDocument
                                       user:(PPUser *)user
                                    success:(void (^)(NSOperation*, PPBaseResponse*))success
                                    failure:(void (^)(NSOperation*, PPBaseResponse*, NSError *))failure
                                   canceled:(void (^)(NSOperation*))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    // 2. create request
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathDeleteDocument:remoteDocument]];
    NSMutableURLRequest *deleteRequest = [[self requestSerializer] requestWithMethod:@"GET"
                                                                           URLString:urlString
                                                                          parameters:requestParams];
    
    AFHTTPRequestOperation *deleteOperation = [[AFHTTPRequestOperation alloc] initWithRequest:deleteRequest];
    deleteOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    deleteOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    [deleteOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:responseObject];
        
        if (success) {
            success(operation, baseResponse);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Delete document failed with response %@", operation.responseString);
        
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:operation.responseObject];
        
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            NSLog(@"Canceled");
            if (canceled) {
                canceled(operation);
            }
            return;
        }
        
        NSLog(@"Error:%@", error);
        if (failure != nil) {
            failure(operation, baseResponse, error);
        }
    }];
    
    return deleteOperation;
}

- (NSOperation*)createConfirmValuesRequest:(PPUserConfirmedValues*)values
                                  document:(PPRemoteDocument*)remoteDocument
                                      user:(PPUser *)user
                                   success:(void (^)(NSOperation*, PPBaseResponse*))success
                                   failure:(void (^)(NSOperation*, PPBaseResponse*, NSError *))failure
                                  canceled:(void (^)(NSOperation*))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    // 2. create request
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathConfirmDataForDocument:remoteDocument]];
    
    // create URL with URL encoded request parameters
    NSMutableURLRequest *confirmRequestUrl = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                           URLString:urlString
                                                                                          parameters:requestParams];
    
    NSMutableURLRequest *confirmRequestBody = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                            URLString:[confirmRequestUrl.URL absoluteString]
                                                                                           parameters:[values dictionaryWithModelObject]];
    
    NSMutableURLRequest *confirmRequest = [[self requestSerializer] requestWithMethod:@"POST"
                                                                            URLString:[confirmRequestUrl.URL absoluteString]
                                                                           parameters:nil];
    
    confirmRequest.HTTPBody = confirmRequestBody.HTTPBody;
    NSString* contentTypeHeader = @"Content-Type";
    [confirmRequest setValue:[confirmRequestBody.allHTTPHeaderFields valueForKey:contentTypeHeader] forHTTPHeaderField:contentTypeHeader];
    
    AFHTTPRequestOperation *confirmOperation = [[AFHTTPRequestOperation alloc] initWithRequest:confirmRequest];
    confirmOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    confirmOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    [confirmOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:responseObject];
        
        if (success) {
            success(operation, baseResponse);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Confirm values failed with response %@", operation.responseString);
        
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:operation.responseObject];
        
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            NSLog(@"Canceled");
            if (canceled) {
                canceled(operation);
            }
            return;
        }
        
        NSLog(@"Error:%@", error);
        if (failure != nil) {
            failure(operation, baseResponse, error);
        }
    }];

    return confirmOperation;
}

- (NSOperation*)createRegisterPushNotificationToken:(NSString*)token
                                            forUser:(PPUser *)user
                                            success:(void (^)(NSOperation*, PPBaseResponse*))success
                                            failure:(void (^)(NSOperation*, PPBaseResponse*, NSError *))failure
                                           canceled:(void (^)(NSOperation*))canceled {
    
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    [requestParams setObject:token forKey:kPPParameterDeviceToken];
    [requestParams setObject:[user userId] forKey:kPPParameterCustomerId];
    
    NSString *urlString = [baseURLString stringByAppendingString:[PPNetworkManager apiPathPushRegistrationForUser:user]];
    NSMutableURLRequest *pushRegisterRequestUrlRequest = [[self requestSerializer] requestWithMethod:@"GET"
                                                                                           URLString:urlString
                                                                                          parameters:requestParams];
    
    NSMutableURLRequest *pushRegisterRequest = [[self requestSerializer] requestWithMethod:@"POST"
                                                                                 URLString:[pushRegisterRequestUrlRequest.URL absoluteString]
                                                                                parameters:nil];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:pushRegisterRequest];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    requestOperation.securityPolicy = [[self requestOperationManager] securityPolicy];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:responseObject];
        
        if (success) {
            success(operation, baseResponse);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Push notify registration failed with response %@", operation.responseString);
        
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:operation.responseObject];
        
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            NSLog(@"Canceled");
            if (canceled) {
                canceled(operation);
            }
            return;
        }
        
        NSLog(@"Error:%@", error);
        if (failure != nil) {
            failure(operation, baseResponse, error);
        }
    }];
    
    return requestOperation;
}

@end
