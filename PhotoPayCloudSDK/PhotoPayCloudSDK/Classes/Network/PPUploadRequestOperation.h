//
//  PPUploadRequestOperation.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPLocalDocument;
@class PPRemoteDocument;
@protocol PPDocumentUploadDelegate;

/**
 Interface which any concrete upload request operation should implement
 
 Any concrete implementation should inherit from NSOperation (e.g. AFJSONRequestOperation)
 */
@protocol PPUploadRequestOperation <NSObject>

@required
/**
 Delegate is also requred. Could be nil.
 */
@property (nonatomic, weak) id<PPDocumentUploadDelegate> delegate;

/**
 Upload progess is stored in progress property
 */
@property (nonatomic, strong) NSNumber* progress;

/**
 Cancels the operation
 */
- (void)cancel;

@end

/**
 Delegate for the upload request operation
 */
@protocol PPDocumentUploadDelegate <NSObject>

@required

/** 
 Success handler is required. UI updates will be required on success 
 */
- (void)localDocument:(PPLocalDocument*)localDocument
didFinishUploadWithResult:(PPRemoteDocument*)remoteDocument;

/**
 Failure handler is required. UI updates will be required on success
 */
- (void)localDocument:(PPLocalDocument*)localDocument
didFailToUploadWithError:(NSError*)error;

@optional

/**
 Progress handler is optional.
 */
- (void)localDocument:(PPLocalDocument*)localDocument
didUpdateProgressWithBytesWritten:(long long)totalBytesWritten
    totalBytesToWrite:(long long)totalBytesToWrite;

/**
 Optional handler for cancellation event
 */
- (void)localDocumentDidCancelUpload:(PPLocalDocument*)localDocument;

@end
