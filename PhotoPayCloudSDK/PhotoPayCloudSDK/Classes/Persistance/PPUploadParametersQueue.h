//
//  PPUploadParametersQueue.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPUploadParameters.h"


@interface PPUploadParametersQueue : NSObject <NSCoding>

/**
 Creates the upload parameters queue for the user with given user ID hash
 */
+ (instancetype)queueForUserIdHash:(NSString*)userIdHash;

/**
 Storage for upload paramter objects
 */
@property (nonatomic, strong) NSMutableArray* elements;

/**
 Retrieves object from the front of the queue
 
 Return value is boolean which is YES of operation was successful, or no otherwise.
 */
- (BOOL)front:(PPUploadParameters*)front;

/**
 Retrieves object from the back of the queue
 
 Return value is boolean which is YES of operation was successful, or no otherwise.
 */
- (BOOL)back:(PPUploadParameters*)back;

/**
 Retrieves and removes object from the front of the queue by reference.
 
 Return value is boolean which is YES of operation was successful, or no otherwise.
 */
- (BOOL)dequeue:(PPUploadParameters*)front;

/**
 Removes the object from the queue.
 
 Sequentially searches the queue for this object.
 */
- (BOOL)remove:(PPUploadParameters*)parameters;

/**
 Adds object to the end of the queue
 
 Return value is boolean which is YES of operation was successful, or no otherwise.
 */
- (BOOL)enqueue:(PPUploadParameters*)parameters;

/**
 Retrieves the number of elements in queue
 */
- (NSUInteger)count;

@end
