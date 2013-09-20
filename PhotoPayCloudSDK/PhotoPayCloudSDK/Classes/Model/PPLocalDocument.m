//
//  PPLocalDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalDocument.h"
#import "PPDocumentManager.h"
#import "NSString+Factory.h"

@interface PPLocalDocument ()

@end

@implementation PPLocalDocument

@synthesize bytes = bytes_;
@synthesize ownerIdHash;
@synthesize uploadRequest;

- (id)initWithBytes:(NSData*)inBytes
       documentType:(PPDocumentType)inDocumentType
     processingType:(PPDocumentProcessingType)inProcessingType {
    
    NSString* filename = [PPLocalDocument generateUniqueFilenameForType:inDocumentType];
    NSURL* documentsDir = [PPDocumentManager urlForFilename:filename];
    
    self = [super initWithDocumentId:filename
                            bytesUrl:documentsDir
                       documentState:PPDocumentStateCreated
                        documentType:inDocumentType
                      processingType:inProcessingType];
    if (self) {
        bytes_ = inBytes;
        ownerIdHash = nil;
        uploadRequest = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    bytes_ = nil;
    ownerIdHash = [decoder decodeObjectForKey:@"ownerIdHash"];
    uploadRequest = nil;
    
    // when deserialized, all local documents should be in state stored
    // state uploading is impossible since it was just deserialized.
    // created is also impossible because then the document wouldnt be stored
    if (self.state == PPDocumentStateUploading) {
        self.state = PPDocumentStateUploadFailed;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.ownerIdHash forKey:@"ownerIdHash"];
}

- (NSString*)description {
    NSString* result = [super description];
    result = [result stringByAppendingFormat:@"Owner ID HASH: %@\n", [self ownerIdHash]];
    return result;
}

/**
 Regular local documents can have access to bytes property only if they are in 
 Stored state.
 */
- (NSData*)bytes {
    if (bytes_ == nil) {
        if ([self state] != PPDocumentStateCreated) {
            NSError *__autoreleasing error = nil;
            bytes_ = [[NSData alloc] initWithContentsOfURL:[self bytesUrl]
                                                   options:NSDataReadingMappedIfSafe
                                                     error:&error];
            if (error != nil) {
                NSLog(@"Bytes cannot be read! %@", [error localizedDescription]);
                bytes_ = nil;
            }
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Local document should be stored before attepting to access bytes"
                                         userInfo:nil];
        }
    }
    return bytes_;
}

- (void)saveUsingDocumentManager:(PPDocumentManager*)documentManager
                         success:(void(^)(PPLocalDocument*localDocument))success
                         failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure {
    
    [documentManager saveDocument:self atUrl:[self bytesUrl]
                          success:^(PPLocalDocument*localDocument) {
                              localDocument.state = PPDocumentStateStored;
                              success(localDocument);
                          }
                          failure:^(PPLocalDocument*localDocument, NSError* error) {
                              failure(localDocument, error);
                          }];
}

+ (NSString*)generateUniqueFilenameForType:(PPDocumentType)type {
    NSString* uuid = [NSString UUID];
    NSString* extension = [PPDocument fileExtensionForDocumentType:type];
    return [NSString stringWithFormat:@"%@.%@", uuid, extension];
}

- (UIImage*)previewImage {
    return nil;
}

- (UIImage*)thumbnailImage {
    return nil;
}

@end
