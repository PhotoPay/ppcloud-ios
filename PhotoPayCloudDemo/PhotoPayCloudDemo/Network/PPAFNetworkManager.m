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

@synthesize httpClient;

- (id)initWithHttpClient:(AFHTTPClient *)inHttpClient {
    self = [super init];
    if (self) {
        httpClient = inHttpClient;
    }
    return self;
}

- (id)httpClient {
    return httpClient;
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
                                                   success:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, PPRemoteDocument *))success
                                                   failure:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, NSError *))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSDictionary *uploadRequestParameters = [self uploadRequestParametersForUser:user
                                                                   localDocument:document
                                                                           error:&error];
    if (error != nil) {
        NSLog(@"%@", [NSString stringWithFormat:@"Error creating request: %@", [error localizedDescription]]);
        failure(nil, document, error);
        return nil;
    }
    
    // 2. create multipart request
    NSMutableURLRequest *multipartRequest =
        [[self httpClient] multipartFormRequestWithMethod:@"POST"
                                                     path:@"/cloud/upload/document"
                                               parameters:uploadRequestParameters
                                constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
                                    [formData appendPartWithFileData:[document bytes]
                                                                name:kPPParameterData
                                                            fileName:[[document cachedDocumentUrl] lastPathComponent]
                                                            mimeType:[document mimeType]];
                                }];
    
    // 3.create upload operation from multipart request and upload parameters object
    PPAFUploadRequestOperation* uploadRequestOperation = [[PPAFUploadRequestOperation alloc] initWithRequest:multipartRequest];
    
    // 4. check for errors
    if (uploadRequestOperation == nil) {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = _(@"PhotoPayErrorUploadCannotCreateRequest");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2002
                                         userInfo:userInfo];
        failure(nil, document, error);
        
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
        NSLog(@"Response object %@", responseObject);
        PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:responseObject];
        PPRemoteDocument* remoteDocument = [baseResponse document];
        
        NSLog(@"Remote document: %@", remoteDocument);
        
        if (success) {
            success(_uploadRequestOperation, document, remoteDocument);
        }
        
        if ([_uploadRequestOperation.delegate respondsToSelector:@selector(localDocument:didFinishUploadWithResult:)]) {
            [_uploadRequestOperation.delegate localDocument:document
                              didFinishUploadWithResult:remoteDocument];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Response %@", operation.responseString);
        
        if (error != nil && error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            
            if (canceled) {
                canceled(_uploadRequestOperation, document);
            }
            
            if ([_uploadRequestOperation.delegate respondsToSelector:@selector(localDocumentDidCancelUpload:)]) {
                [_uploadRequestOperation.delegate localDocumentDidCancelUpload:document];
            }
            
            return;
        } else {
            
            if (failure) {
                failure((id<PPUploadRequestOperation>)operation, document, error);
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
        
        failure(_uploadRequestOperation, document, error);
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
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSArray *))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                        canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
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
    NSMutableURLRequest *getRequest = [[self httpClient] requestWithMethod:@"GET"
                                                                      path:[NSString stringWithFormat:@"/cloud/customer/documents/%@", [user userId]]
                                                                parameters:requestParams];
    
    AFJSONRequestOperation *getRequestOperation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:getRequest
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:JSON];
                                                            
                                                            if (success) {
                                                                success(request, response, [baseResponse documentsList]);
                                                            }
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                            if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
                                                                    NSLog(@"request canceled");
                                                                    if (canceled) {
                                                                        canceled(request, response);
                                                                    }
                                                                    return;
                                                                }
                                                                
                                                                NSLog(@"failed to execute request %@", error.description);
                                                                
                                                                if (failure != nil) {
                                                                    failure(request, response, error);
                                                                }
                                                        }];
    
    return getRequestOperation;
    
}

- (NSOperation*)createGetImageRequestForDocument:(PPRemoteDocument*)remoteDocument
                                            user:(PPUser *)user
                                       imageSize:(PPImageSize)imageSize
                                     imageFormat:(PPImageFormat)imageFormat
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                        canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
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
    
    NSMutableURLRequest *urlRequest = [[self httpClient] requestWithMethod:@"GET"
                                                                      path:[NSString stringWithFormat:@"cloud/image/%@", [remoteDocument documentId]]
                                                                parameters:requestParams];
        
    AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail! %@", error);
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            if (canceled) {
               canceled(operation.request, operation.response);
            }
            return;
        }
        
        if (failure != nil) {
            failure(operation.request, operation.response, error);
        }
    }];

    return requestOperation;
}

- (NSOperation*)createGetDocumentData:(PPRemoteDocument*)remoteDocument
                                 user:(PPUser *)user
                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *image))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                             canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    NSMutableURLRequest *urlRequest = [[self httpClient] requestWithMethod:@"GET"
                                                                      path:[NSString stringWithFormat:@"cloud/document/%@/data", [remoteDocument documentId]]
                                                                parameters:requestParams];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            if (canceled) {
                canceled(operation.request, operation.response);
            }
            return;
        }
        
        if (failure != nil) {
            NSLog(@"Fail! %@", error);
            
            failure(operation.request, operation.response, error);
        }
    }];
    
    return requestOperation;
}

- (NSOperation*)createDeleteDocumentRequest:(PPRemoteDocument*)remoteDocument
                                       user:(PPUser *)user
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, PPBaseResponse *baseResonse))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                   canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    // 2. create request
    NSMutableURLRequest *deleteRequest = [[self httpClient] requestWithMethod:@"GET"
                                                                         path:[NSString stringWithFormat:@"/cloud/delete/%@", [remoteDocument documentId]]
                                                                   parameters:requestParams];
    
    NSLog(@"Request %@", deleteRequest);
    
    AFJSONRequestOperation *deleteOperation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:deleteRequest
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            NSLog(@"Deleting %@", JSON);
                                                            PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:JSON];
                                                        
                                                            if (success) {
                                                                success(request, response, baseResponse);
                                                            }
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                            if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
                                                                NSLog(@"request canceled");
                                                                if (canceled) {
                                                                    canceled(request, response);
                                                                }
                                                                return;
                                                            }
                                                            
                                                            NSLog(@"failed to execute request %@", error.description);
                                                            
                                                            if (failure != nil) {
                                                                failure(request, response, error);
                                                            }
                                                        }];
    
    return deleteOperation;
}

- (NSOperation*)createConfirmValuesRequest:(PPUserConfirmedValues*)values
                                  document:(PPRemoteDocument*)remoteDocument
                                      user:(PPUser *)user
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, PPBaseResponse *baseResonse))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *))failure
                                  canceled:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSMutableDictionary* requestParams = [self requestParametersForUser:user error:&error];
    if (error != nil) {
        return nil;
    }
    
    // 2. create request
    NSMutableURLRequest *confirmRequest = [[self httpClient] requestWithMethod:@"POST"
                                                                          path:[NSString stringWithFormat:@"/cloud/payment/%@", [remoteDocument documentId]]
                                                                   parameters:requestParams];
    
    NSLog(@"Request %@", confirmRequest);
    
    AFJSONRequestOperation *confirmOperation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:confirmRequest
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            NSLog(@"Deleting %@", JSON);
                                                            PPBaseResponse* baseResponse = [[PPBaseResponse alloc] initWithDictionary:JSON];
                                                            
                                                            if (success) {
                                                                success(request, response, baseResponse);
                                                            }
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                            if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
                                                                NSLog(@"request canceled");
                                                                if (canceled) {
                                                                    canceled(request, response);
                                                                }
                                                                return;
                                                            }
                                                            
                                                            NSLog(@"failed to execute request %@", error.description);
                                                            
                                                            if (failure != nil) {
                                                                failure(request, response, error);
                                                            }
                                                        }];
    
    return confirmOperation;

}

@end
