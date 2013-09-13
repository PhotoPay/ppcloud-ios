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
        if (*error != nil) {
            *error = [NSError errorWithDomain:domain
                                         code:2001
                                     userInfo:userInfo];
        }
    }
    
    // set user type if specified (if not specified, server default will be used
    if ([user userType] != PPUserTypeDefault) {
        [uploadRequestParams setObject:[PPUser objectForUserType:[user userType]] forKey:@"customerType"];
    }
    
    // set organization id if specified (if not specified, server default will be used
    if ([user organizationId] != nil && [[user organizationId] length] != 0) {
        [uploadRequestParams setObject:[user organizationId] forKey:@"organizationId"];
    } else {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadOrganisationIdNotSet";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        if (*error != nil) {
            *error = [NSError errorWithDomain:domain
                                         code:2004
                                     userInfo:userInfo];
        }
    }
    
    // set request type (this will always be specified)
    [uploadRequestParams setObject:[PPDocument objectForDocumentProcessingType:[[uploadParameters localDocument] processingType]]
                            forKey:@"requestType"];
    
    // file type will also always be specified
    [uploadRequestParams setObject:[PPDocument objectForDocumentType:[[uploadParameters localDocument] documentType]]
                            forKey:@"fileType"];
    
    // file type will also always be specified
    [uploadRequestParams setObject:@([uploadParameters pushNotify])
                            forKey:@"pushNotify"];
    
    // callback URL and device token are never sent
    
    return uploadRequestParams;
}

- (id<PPUploadRequestOperation>)createUploadRequestForUser:(PPUser *)user
                                          uploadParameters:(PPUploadParameters *)uploadParameters
                                                   success:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, PPRemoteDocument *))success
                                                   failure:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *, NSError *))failure
                                                  canceled:(void (^)(id<PPUploadRequestOperation>, PPLocalDocument *))canceled {
    // 1. create parameters dictionary
    NSError * __autoreleasing error = nil;
    NSDictionary *uploadRequestParameters = [self uploadRequestParametersForUser:user
                                                                uploadParameters:uploadParameters
                                                                           error:&error];
    
    PPLocalDocument *localDocument = [uploadParameters localDocument];
    if (error != nil) {
        failure(nil, localDocument, error);
    
        return nil;
    }
    
    // 2. create multipart request
    NSMutableURLRequest *multipartRequest =
        [[self httpClient] multipartFormRequestWithMethod:@"POST"
                                                     path:@"/upload/document"
                                               parameters:uploadRequestParameters
                                constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
                                    NSLog(@"Appending filename %@", [[[uploadParameters localDocument] url] lastPathComponent]);
                                    
                                    [formData appendPartWithFileData:[[uploadParameters localDocument] bytes]
                                                                name:@"data"
                                                            fileName:[[[uploadParameters localDocument] url] lastPathComponent]
                                                            mimeType:[[uploadParameters localDocument] mimeType]];
                                }];
    
    // 3.create upload operation from multipart request and upload parameters object
    PPAFUploadRequestOperation* uploadRequestOperation = [[PPAFUploadRequestOperation alloc] initWithRequest:multipartRequest
                                                                                            uploadParameters:uploadParameters];
    
    // 4. check for errors
    if (uploadRequestOperation == nil) {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadCannotCreateRequest";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        NSError *error = [NSError errorWithDomain:domain
                                             code:2002
                                         userInfo:userInfo];
        failure(nil, localDocument, error);
        
        return nil;
    }
    
    __weak PPAFUploadRequestOperation* _uploadRequestOperation = uploadRequestOperation;
    
    // 5. add upload progress block
    [uploadRequestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        _uploadRequestOperation.progress = [[NSNumber alloc] initWithDouble:totalBytesWritten / (double)totalBytesExpectedToWrite];
        
        if ([_uploadRequestOperation.delegate respondsToSelector:@selector(uploadRequestOperation:didUpdateProgressForDocument:totalBytesWritten:totalBytesToWrite:)]) {
            [[_uploadRequestOperation delegate] uploadRequestOperation:_uploadRequestOperation
                                          didUpdateProgressForDocument:localDocument
                                                     totalBytesWritten:totalBytesWritten
                                                     totalBytesToWrite:totalBytesExpectedToWrite];
        }
    }];
    
    // 6. add success, failure and cancellation blocks
    [uploadRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        PPRemoteDocument* remoteDocument = [[PPRemoteDocument alloc] initWithDictionary:responseObject];
        
        if (success) {
            success((id<PPUploadRequestOperation>)operation, localDocument, remoteDocument);
        }
        
        [_uploadRequestOperation.delegate uploadRequestOperation:_uploadRequestOperation
                                               didUploadDocument:localDocument
                                                      withResult:remoteDocument];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to execute upload %@", [error localizedDescription]);
        
        if (error != nil && error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
            
            if (canceled) {
                canceled((id<PPUploadRequestOperation>)operation, localDocument);
            }
            
            if ([_uploadRequestOperation.delegate respondsToSelector:@selector(uploadRequestOperation:didCancelUploadingDocument:)]) {
                [_uploadRequestOperation.delegate uploadRequestOperation:_uploadRequestOperation
                                              didCancelUploadingDocument:localDocument];
            }
            
            return;
        } else {
            
            if (failure) {
                failure((id<PPUploadRequestOperation>)operation, localDocument, error);
            }
            
            [_uploadRequestOperation.delegate uploadRequestOperation:_uploadRequestOperation
                                             didFailToUploadDocument:localDocument
                                                           withError:error];
        }
    }];
    
    // 7. done
    return uploadRequestOperation;
}

@end
