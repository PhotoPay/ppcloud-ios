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
@protocol PPUploadRequestOperationDelegate;

/**
 Interface which any concrete upload request operation should implement
 
 Any concrete implementation should inherit from NSOperation (e.g. AFJSONRequestOperation)
 */
@protocol PPUploadRequestOperation <NSObject>

@required
/**
 Delegate is also requred. Could be nil.
 */
@property (nonatomic, weak) id<PPUploadRequestOperationDelegate> delegate;

/**
 Upload progess is stored in progress property
 */
@property (nonatomic, strong) NSNumber* progress;

@end

/**
 Delegate for the upload request operation
 */
@protocol PPUploadRequestOperationDelegate <NSObject>

@required

/** 
 Success handler is required. UI updates will be required on success 
 */
- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
             didUploadDocument:(PPLocalDocument*)localDocument
                    withResult:(PPRemoteDocument*)remoteDocument;

/**
 Failure handler is required. UI updates will be required on success
 */
- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
       didFailToUploadDocument:(PPLocalDocument*)localDocument
                     withError:(NSError*)error;

@optional

/**
 Progress handler is optional. It's possible to update UI on progress.
 */
- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
  didUpdateProgressForDocument:(PPLocalDocument*)localDocument
             totalBytesWritten:(long long)totalBytesWritten
             totalBytesToWrite:(long long)totalBytesToWrite;

/**
 Optional handler for cancellation event
 */
- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
    didCancelUploadingDocument:(PPLocalDocument*)localDocument;

@end
