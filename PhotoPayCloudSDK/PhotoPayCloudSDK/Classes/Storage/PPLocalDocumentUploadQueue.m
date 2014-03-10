//
//  PPLocalDocumentUploadQueue.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalDocumentUploadQueue.h"
#import "UIApplication+Documents.h"
#import "PPLocalDocument.h"
#import "PPSdk.h"

@implementation PPLocalDocumentUploadQueue

@synthesize elements;

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    elements = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    elements = [decoder decodeObjectForKey:@"elements"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.elements forKey:@"elements"];
}

+ (instancetype)queueForUserIdHash:(NSString*)userIdHash {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:userIdHash]];
}

- (BOOL)remove:(PPLocalDocument*)document {
    NSUInteger countBefore = [[self elements] count];
    [self.elements removeObject:document];
    BOOL success = [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:[document ownerIdHash]]];
    if (success && (countBefore - 1 == [[self elements] count])) {
        PPLogDebug(@"Removed document from upload queue, now count is %u", (unsigned int) self.elements.count);
    } else {
        PPLogError(@"Failed to remove document from upload queue!");
    }
    return success;
}

- (NSUInteger)indexOfDocument:(PPLocalDocument*)document {
    return [self.elements indexOfObject:document];
}

- (BOOL)insert:(PPLocalDocument*)document {
    NSInteger index = [self indexOfDocument:document];
    
    if (index == NSNotFound) {
        [self.elements addObject:document];
        index = self.elements.count;
    } else {
        [self.elements replaceObjectAtIndex:index withObject:document];
    }
    BOOL saved = [NSKeyedArchiver archiveRootObject:self
                                             toFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:[document ownerIdHash]]];
    
    if (saved) {
        PPLogVerbose(@"Inserting document into upload queue, at position %d", (int)index);
    } else {
        PPLogError(@"Failed to insert document into upload queue!");
    }
    return saved;
}

- (NSUInteger)count {
    return [self.elements count];
}

+ (NSString*)serializationPathForUserIdHash:(NSString*)userIdHash {
    if (userIdHash == nil) {
        PPLogError(@"User ID hash is nil. Cannot create document upload queue");
        return nil;
    }
    NSError * __autoreleasing error;
    NSString* basePath = [[UIApplication pp_applicationDocumentsDirectoryWithError:&error] path];
    
    if (basePath == nil) {
        return nil;
    }
    
    return [basePath stringByAppendingFormat:@"/%@.params", userIdHash];
}

@end
