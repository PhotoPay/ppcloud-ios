//
//  PPLocalDocumentUploadQueue.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPLocalDocument;

@interface PPLocalDocumentUploadQueue : NSObject <NSCoding>

/**
 Creates the upload parameters queue for the user with given user ID hash
 */
+ (instancetype)queueForUserIdHash:(NSString*)userIdHash;

/**
 Storage for upload paramter objects
 */
@property (nonatomic, strong) NSMutableArray* elements;

/**
 Removes the object from the queue.
 
 Sequentially searches the queue for this object.
 */
- (BOOL)remove:(PPLocalDocument*)document;

/**
 Adds object to the queue
 
 Return value is boolean which is YES of operation was successful, or no otherwise.
 */
- (BOOL)insert:(PPLocalDocument*)document;

/**
 Returns the index of local document in the upload queue.
 
 If document is not in the queue, returns NSNotFound
 */
- (NSUInteger)indexOfDocument:(PPLocalDocument*)document;

/**
 Retrieves the number of elements in queue
 */
- (NSUInteger)count;

/**
 Path to a file in which the users upload information is stored
 */
+ (NSString*)serializationPathForUserIdHash:(NSString*)userIdHash;

@end
