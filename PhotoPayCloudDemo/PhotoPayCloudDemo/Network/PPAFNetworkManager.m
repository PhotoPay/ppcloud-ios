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

- (NSDictionary*)uploadRequestParametersForUser:(PPUser*)user
                                  localDocument:(PPLocalDocument*)document
                                          error:(NSError**)error {
    
    NSMutableDictionary *uploadRequestParams = [[NSMutableDictionary alloc] init];
    
    // set user id and check for possible error
    if ([user userId] != nil && [[user userId] length] != 0) {
        [uploadRequestParams setObject:[user userId] forKey:@"customerId"];
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
        [uploadRequestParams setObject:[PPUser objectForUserType:[user userType]] forKey:@"customerType"];
    }
    
    // set organization id if specified (if not specified, server default will be used
    if ([user organizationId] != nil && [[user organizationId] length] != 0) {
        [uploadRequestParams setObject:[user organizationId] forKey:@"organizationId"];
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
    
    // set request type (this will always be specified)
    [uploadRequestParams setObject:[PPDocument objectForDocumentProcessingType:[document processingType]]
                            forKey:@"requestType"];
    
    // file type will also always be specified
    [uploadRequestParams setObject:[PPDocument objectForDocumentType:[document documentType]]
                            forKey:@"fileType"];
    
    // file type will also always be specified
    [uploadRequestParams setObject:@(([[PPPhotoPayCloudService sharedService] deviceToken] != nil))
                            forKey:@"pushNotify"];
    
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
                                                                name:@"data"
                                                            fileName:[[document url] lastPathComponent]
                                                            mimeType:[document mimeType]];
                                }];
    
    // 3.create upload operation from multipart request and upload parameters object
    PPAFUploadRequestOperation* uploadRequestOperation = [[PPAFUploadRequestOperation alloc] initWithRequest:multipartRequest];
    
    // 4. check for errors
    if (uploadRequestOperation == nil) {
        NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
        NSString *desc = @"PhotoPayErrorUploadCannotCreateRequest";
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
        PPRemoteDocument* remoteDocument = [[PPRemoteDocument alloc] initWithDictionary:responseObject];
        
        NSLog(@"Response %@", responseObject);
        
        if (success) {
            success(_uploadRequestOperation, document, remoteDocument);
        }
        
        [_uploadRequestOperation.delegate localDocument:document
                              didFinishUploadWithResult:remoteDocument];
        
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
            
            [_uploadRequestOperation.delegate localDocument:document
                                   didFailToUploadWithError:error];
        }
    }];
    
    // 7. execute as background task
    [uploadRequestOperation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^() {
        
    }];
    
    // 7. done
    return uploadRequestOperation;
}

@end
