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
#import "PPSdk.h"

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
    NSURL* documentUrl = [PPDocumentManager urlForFilename:filename];
    
    self = [super initWithDocumentId:filename
                   cachedDocumentUrl:documentUrl
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

- (id)initWithURL:(NSURL*)inUrl
     documentType:(PPDocumentType)inDocumentType
   processingType:(PPDocumentProcessingType)inProcessingType {
    
    self = [super initWithDocumentId:[inUrl lastPathComponent]
                   cachedDocumentUrl:inUrl
                       documentState:PPDocumentStateStored
                        documentType:inDocumentType
                      processingType:inProcessingType];
    if (self) {
        bytes_ = nil;
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

- (id)copyWithZone:(NSZone *)zone {
    PPLocalDocument *another = [super copyWithZone:zone];
    another->bytes_ = self->bytes_;
    another->ownerIdHash = self->ownerIdHash;
    another->uploadRequest = self->uploadRequest;
    return another;
}

- (NSString*)description {
    NSString* result = [super description];
    result = [result stringByAppendingFormat:@"\nOwner ID HASH: %@", [self ownerIdHash]];
    if ([self uploadRequest]) {
        result = [result stringByAppendingFormat:@"\nUpload request %p", [self uploadRequest]];
    }
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
            bytes_ = [[NSData alloc] initWithContentsOfURL:[self cachedDocumentUrl]
                                                   options:NSDataReadingMappedIfSafe
                                                     error:&error];
            if (error != nil) {
                PPLogError(@"Bytes cannot be read! %@", [error localizedDescription]);
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

- (void)documentBytesWithSuccess:(void (^)(NSData* bytes))success
                         failure:(void (^)(void))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self bytes] != nil) {
            if (success) {
                success([self bytes]);
            }
        } else {
            if (failure) {
                failure();
            }
        }
    });
}

- (void)saveUsingDocumentManager:(PPDocumentManager*)documentManager
                         success:(void(^)(PPLocalDocument*localDocument))success
                         failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure {
    
    [documentManager saveDocument:self atUrl:[self cachedDocumentUrl]
                          success:^(PPLocalDocument*localDocument) {
                              localDocument.state = PPDocumentStateStored;
                              success(localDocument);
                          }
                          failure:^(PPLocalDocument*localDocument, NSError* error) {
                              failure(localDocument, error);
                          }];
}

- (BOOL)reloadWithDocument:(PPDocument*)other {
    PPLocalDocument* otherLocalDocument = [other localDocument];
    if (![self isEqual:otherLocalDocument]) {
        return NO;
    }
    
    BOOL changed = NO;
    
    if (self.state != other.state) {
        self.state = other.state;
        changed = YES;
    }
    
    if (self.documentType == PPDocumentTypeUnknown) {
        self.documentType = otherLocalDocument.documentType;
        changed = YES;
    }
    
    if (self.bytes == nil && otherLocalDocument.bytes != nil) {
        bytes_ = otherLocalDocument.bytes;
        changed = YES;
    }
    
    return changed;
}

+ (NSString*)generateUniqueFilenameForType:(PPDocumentType)type {
    NSString* uuid = [NSString pp_UUID];
    NSString* extension = [PPDocument fileExtensionForDocumentType:type];
    return [NSString stringWithFormat:@"%@.%@", uuid, extension];
}

@end
