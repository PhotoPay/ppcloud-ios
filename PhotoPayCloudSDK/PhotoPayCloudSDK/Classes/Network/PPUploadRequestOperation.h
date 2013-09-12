//
//  PPUploadRequestOperation.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPUploadParameters;
@class PPDocument;
@protocol PPUploadRequestOperationDelegate;

/**
 Interface which any concrete upload request operation should implement
 
 Any concrete implementation should inherit from NSOperation (e.g. AFJSONRequestOperation)
 */
@protocol PPUploadRequestOperation <NSObject>

@required

/**
 Each upload request operation need to have exactly one upload parameters object
 */
@property (nonatomic, strong, readonly) PPUploadParameters* uploadParameters;

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
       didCompleteWithDocument:(PPDocument*)document;

/**
 Failure handler is required. UI updates will be required on success
 */
- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
          didCompleteWithError:(NSError*)error;

@optional

/**
 Progress handler is optional. It's possible to update UI on progress.
 */
- (void)uploadRequestOperationDidUpdateProgress:(id<PPUploadRequestOperation>)operation
                              totalBytesWritten:(long long)totalBytesWritten
                              totalBytesToWrite:(long long)totalBytesToWrite;

/**
 Optional handler for cancellation event
 */
- (void)uploadRequestOperationDidCancel:(id<PPUploadRequestOperation>)operation;

@end
