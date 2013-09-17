//
//  PPLocalDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalDocument.h"
#import "PPDocumentManager.h"

@interface PPLocalDocument ()

/**
 URL pointing to the location of the document.
 Can be url both local or remote
 */
@property (nonatomic, strong) NSURL* url;

@end

@implementation PPLocalDocument

@synthesize bytes = bytes_;
@synthesize ownerIdHash;
@synthesize uploadRequest;

- (id)initWithBytes:(NSData*)inBytes
       documentType:(PPDocumentType)inDocumentType
     processingType:(PPDocumentProcessingType)inProcessingType {
    self = [super initWithUrl:nil
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
 There are two states in which a local document can be found.
 From all of these states properties URL and BYTES must be reachable.
 
 To ensure this, this custom getter is provided. We handle these cases:
 
 1. BYTES property is nil
        BYTES is initialized from the file to which URL is pointing
 2. BYTES is available
        simply return that value
 
 There is one more case which is handled in different way. 
 For every local document it's ensured that before requesting BYTES property URL property will be set.
 This is ensured implicitly, by always calling [localDocument saveUsingDocumentManager:success:failure] before 
 accessing BYTES property.
 */
- (NSData*)bytes {
    if (bytes_ == nil) {
        if ([self url] == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Local document should have either URL or BYTES property set. Save the document using saveUsingDocumentManager:success:failure and use the bytes property in callbacks only"
                                         userInfo:nil];
        }
        NSError *__autoreleasing error = nil;
        bytes_ = [[NSData alloc] initWithContentsOfURL:[self url] options:NSDataReadingMappedIfSafe error:&error];
        if (error != nil) {
            NSLog(@"Bytes cannot be read! %@", [error localizedDescription]);
            bytes_ = nil;
        }
    }
    return bytes_;
}

- (void)saveUsingDocumentManager:(PPDocumentManager*)documentManager
                         success:(void(^)(PPLocalDocument*localDocument, NSURL* documentUrl))success
                         failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure {
    
    [documentManager saveDocument:self
                          success:^(PPLocalDocument*localDocument, NSURL* documentUrl) {
                              localDocument.url = documentUrl;
                              localDocument.state = PPDocumentStateStored;
                              success(localDocument, documentUrl);
                          }
                          failure:^(PPLocalDocument*localDocument, NSError* error) {
                              failure(localDocument, error);
                          }];
}

@end
