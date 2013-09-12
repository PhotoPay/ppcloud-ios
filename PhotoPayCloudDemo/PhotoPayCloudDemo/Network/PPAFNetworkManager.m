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
 Prepares the request parameters dictionary with user and upload data
 Also performs error checking so any errors in the request will be immediately reported,
 without the need for waiting rejection from the server
 */
- (NSDictionary*)uploadRequestParametersForUser:(PPUser*)user
                               uploadParameters:(PPUploadParameters*)uploadParameters
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

- (NSDictionary*)uploadRequestParametersForUser:(PPUser*)user
                               uploadParameters:(PPUploadParameters*)uploadParameters
                                          error:(NSError**)error {
    
    NSMutableDictionary *uploadRequestParams = [[NSMutableDictionary alloc] init];
    
    // set user id and check for possible error
    if ([user userId] != nil && [[user userId] length] != 0) {
        [uploadRequestParams setObject:[user userId] forKey:@"customerId"];
    } else {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadUserIdNotSet";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        *error = [NSError errorWithDomain:domain
                                     code:2001
                                 userInfo:userInfo];
    }
    
    // set user type if specified (if not specified, server default will be used
    if ([user userType] != PPUserTypeDefault) {
        [uploadRequestParams setObject:[PPUser objectForUserType:[user userType]] forKey:@"customerType"];
    }
    
    // set organization id if specified (if not specified, server default will be used
    if ([user organizationId] != nil && [[user organizationId] length] != 0) {
        [uploadRequestParams setObject:[user organizationId] forKey:@"organizationId"];
    }
    
    // set request type (this will always be specified)
    [uploadRequestParams setObject:[PPPhotoPayCloudService objectForDocumentProcessingType:[uploadParameters processingType]]
                            forKey:@"requestType"];
    
    // file type will also always be specified
    [uploadRequestParams setObject:[PPDocument objectForDocumentType:[uploadParameters localDocumentType]]
                            forKey:@"fileType"];
    
    // file type will also always be specified
    [uploadRequestParams setObject:@([uploadParameters pushNotify])
                            forKey:@"pushNotify"];
    
    // callback URL and device token are never sent
    
    return uploadRequestParams;
}

- (id<PPUploadRequestOperation>)createUploadRequestForUser:(PPUser*)user
                                          uploadParameters:(PPUploadParameters*)uploadParameters
                                                   success:(void (^)(id<PPUploadRequestOperation> request, PPDocument* document))success
                                                   failure:(void (^)(id<PPUploadRequestOperation> request, NSError *error))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation> request))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSDictionary *uploadRequestParameters = [self uploadRequestParametersForUser:user
                                                                uploadParameters:uploadParameters
                                                                           error:&error];
    if (error != nil) {
        failure(nil, error);
    }
    
    // 2. create multipart request
    NSMutableURLRequest *multipartRequest =
        [[self httpClient] multipartFormRequestWithMethod:@"POST"
                                                     path:@"/upload/document"
                                               parameters:uploadRequestParameters
                                constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
                                    __autoreleasing NSError *error;
                                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:[[uploadParameters localDocumentUrl] path]]
                                                               name:@"data"
                                                              error:&error];
                                }];
    
    // 3.create upload operation from multipart request
    PPAFUploadRequestOperation* uploadRequestOperation = [[PPAFUploadRequestOperation alloc] initWithRequest:multipartRequest];
    
    // 4. check for errors
    if (uploadRequestOperation == nil) {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadCannotCreateRequest";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2002
                                         userInfo:userInfo];
        failure(nil, error);
    }
    
    __weak PPAFUploadRequestOperation* _uploadRequestOperation = uploadRequestOperation;
    
    // 5. add upload progress block
    [uploadRequestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        _uploadRequestOperation.progress = [[NSNumber alloc] initWithDouble:totalBytesWritten / (double)totalBytesExpectedToWrite];
        
        if ([_uploadRequestOperation.delegate respondsToSelector:@selector(uploadRequestOperationDidUpdateProgress:totalBytesWritten:totalBytesToWrite:)]) {
            [[_uploadRequestOperation delegate] uploadRequestOperationDidUpdateProgress:_uploadRequestOperation
                                                                      totalBytesWritten:totalBytesWritten
                                                                      totalBytesToWrite:totalBytesExpectedToWrite];
        }
    }];
    
    // 6. add success, failure and cancellation blocks
    [uploadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPDocument* document = [[PPDocument alloc] initWithDictionary:responseObject];
        
        if (success) {
            success((id<PPUploadRequestOperation>)operation, document);
        }
        
        [_uploadRequestOperation.delegate uploadRequestOperation:_uploadRequestOperation
                                         didCompleteWithDocument:document];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to execute upload %@", [error localizedDescription]);
        
        if (error != nil && error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            
            if (canceled) {
                canceled((id<PPUploadRequestOperation>)operation);
            }
            
            if ([_uploadRequestOperation.delegate respondsToSelector:@selector(uploadRequestOperationDidCancel:)]) {
                [_uploadRequestOperation.delegate uploadRequestOperationDidCancel:_uploadRequestOperation];
            }
            
            return;
        } else {
            
            if (failure) {
                failure((id<PPUploadRequestOperation>)operation, error);
            }
            
            [_uploadRequestOperation.delegate uploadRequestOperation:_uploadRequestOperation
                                                didCompleteWithError:error];
        }
    }];
    
    // 7. done
    return uploadRequestOperation;
}

@end
