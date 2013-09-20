//
//  UIApplication+Documents.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/9/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "UIApplication+Documents.h"

@implementation UIApplication (Documents)

+ (NSURL*)applicationDocumentsDirectoryWithError:(NSError**)error {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask];
    
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[appDirectory path]]) {
        
        // Create Directory!
        __autoreleasing NSError *errorObject = nil;
        BOOL ok = [[NSFileManager defaultManager] createDirectoryAtPath:[appDirectory path]
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&errorObject];
        if (!ok) {
            NSString *domain = @"net.photopay.cloud.sdk.ErrorDomain";
            NSString *desc = @"PhotoPayErrorDocumentsUnavailable";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
            if (error != nil) {
                *error = [NSError errorWithDomain:domain
                                             code:1001
                                         userInfo:userInfo];
            }
            return nil;
        }
    }
    
    return appDirectory;
}

+ (NSURL*)createFileWithData:(NSData*)data
                    filename:(NSString*)filename
                       error:(NSError**)error {
    NSURL* documentsDir = [UIApplication applicationDocumentsDirectoryWithError:error];
    if (documentsDir == nil) {
        return nil;
    }
    
    if (data && documentsDir) {
        NSURL *fileURL = [documentsDir URLByAppendingPathComponent:filename];
        
        NSDataWritingOptions options = NSDataWritingAtomic | NSDataWritingFileProtectionComplete;
        
        BOOL res = [data writeToURL:fileURL
                            options:options
                              error:error];
        if (!res) {
            return nil;
        } else {
            return fileURL;
        }
    }
    
    return nil;
}

+ (NSURL*)createFileWithData:(NSData*)data
                         url:(NSURL*)url
                       error:(NSError**)error {
    if (data && url) {
        NSDataWritingOptions options = NSDataWritingAtomic | NSDataWritingFileProtectionComplete;
        
        BOOL res = [data writeToURL:url
                            options:options
                              error:error];
        if (!res) {
            return nil;
        } else {
            return url;
        }
    }
    
    return nil;
}

+ (BOOL)deleteFolder:(NSString*)folderName
               error:(NSError**)error {
    NSURL* documentsDir = [UIApplication applicationDocumentsDirectoryWithError:error];
    if (documentsDir == nil) {
        return NO;
    }
    
    NSURL* folderPath = [documentsDir URLByAppendingPathComponent:folderName];
    return [UIApplication deleteFileWithUrl:folderPath error:error];
}

+ (BOOL)createFolder:(NSString*)folderName
               error:(NSError**)error {
    NSURL* documentsDir = [UIApplication applicationDocumentsDirectoryWithError:error];
    if (documentsDir == nil) {
        return NO;
    }
    
    NSURL* folderPath = [documentsDir URLByAppendingPathComponent:folderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[folderPath path]]) {
        if ([[NSFileManager defaultManager] createDirectoryAtPath:[folderPath path]
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:error]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

+ (BOOL)deleteFileWithUrl:(NSURL*)url
                    error:(NSError**)error {
    return [[NSFileManager defaultManager] removeItemAtURL:url
                                                     error:error];
}

+ (NSMutableArray*)getAllFilesInFolder:(NSURL*)folderName {
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir;
    if (![fileManager fileExistsAtPath:[folderName path] isDirectory:&isDir] || !isDir) {
        return files;
    }
    
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:[folderName path]];
    if (dirEnum == NULL) {
        return files;
    }
    
    NSString *nextFile;
    while (nextFile = [dirEnum nextObject]) {
        NSURL *nextFromPath = [folderName URLByAppendingPathComponent:nextFile];
        [fileManager fileExistsAtPath:[nextFromPath path] isDirectory:&isDir];
        if (!isDir) {
            [files addObject:[nextFromPath path]];
        }
    }
    
    return files;
}

@end
