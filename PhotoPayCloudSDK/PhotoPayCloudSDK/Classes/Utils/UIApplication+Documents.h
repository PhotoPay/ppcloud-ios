//
//  UIApplication+Documents.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/9/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Documents)

/**
 Returns the URL which points to documents directory of the current application
 */
+ (NSURL*)applicationDocumentsDirectoryWithError:(NSError**)error;

/**
 Saves the data to inside the application's documents directory under specified filename
 
 Returns the NSURL object to saved file.
 */
+ (NSURL*)createFileWithData:(NSData*)data
                    filename:(NSString*)filename
                        error:(NSError**)error;

/**
 Saves the data under specified URL. Must be under application documents directoru
 
 Returns the NSURL object to saved file.
 */
+ (NSURL*)createFileWithData:(NSData*)data
                         url:(NSURL*)url
                       error:(NSError**)error;

/**
 Deletes the file with specified URL.
 
 Error object can be used to get info about any possible errors
 */
+ (BOOL)deleteFileWithUrl:(NSURL*)url
                    error:(NSError**)error;

/**
 Creates a folder with specified name inside documents directory
 */
+ (BOOL)createFolder:(NSString*)folderName
               error:(NSError**)error;

/**
 Deletes a folder with specified name inside documents directory
 */
+ (BOOL)deleteFolder:(NSString*)folderName
               error:(NSError**)error;

/**
 Retrieves a list of all files in a given folder.
 
 Only root folder will be searched, subfolders won't be traversed.
 */
+ (NSMutableArray*)getAllFilesInFolder:(NSURL*)folderName;

@end
