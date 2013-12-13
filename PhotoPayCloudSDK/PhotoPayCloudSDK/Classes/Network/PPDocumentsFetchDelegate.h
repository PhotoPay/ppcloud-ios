//
//  PPDocumentsFetchDelegate.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 12/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPPhotoPayCloudService.h"

/**
 Delegate protocol for documents fetching.
 
 Allows notifications about success/fail of documents fetching, not about
 the documents itself
 
 For the actual documents, use dataSource property of 
 [PPPhotoPayCloudService sharedService] object.
 */
@protocol PPDocumentsFetchDelegate <NSObject>

@optional

/**
 Called when a request for documents fetch is initiated
 */
- (void)cloudServiceDidStartFetchingDocuments:(PPPhotoPayCloudService*)service;

/**
 Called when documents fetching failed with error
 */
- (void)cloudService:(PPPhotoPayCloudService*)service
didFailedFetchingWithError:(NSError*)error;

/**
 Called when a request for documents fetch is initiated
 */
- (void)cloudServiceDidCancelFetchingDocuments:(PPPhotoPayCloudService*)service;

/**
 Called when documents fetching finished with success.
 
 The list of documents is passed as a parameter.
 */
- (void)cloudService:(PPPhotoPayCloudService*)service
didFinishFetchingWithDocuments:(NSArray*)documents;

@end
