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
    [self.elements removeObject:document];
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:[document ownerIdHash]]];
}

- (BOOL)insert:(PPLocalDocument*)document {
    NSInteger index = [self.elements indexOfObject:document];
    if (index == NSNotFound) {
        [self.elements addObject:document];
    } else {
        [self.elements replaceObjectAtIndex:index withObject:document];
    }
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:[document ownerIdHash]]];
}

- (NSUInteger)count {
    return [self.elements count];
}

+ (NSString*)serializationPathForUserIdHash:(NSString*)userIdHash {
    NSError * __autoreleasing error;
    NSString* basePath = [[UIApplication pp_applicationDocumentsDirectoryWithError:&error] path];
    
    if (basePath == nil) {
        return nil;
    }
    
    return [basePath stringByAppendingFormat:@"/%@.params", userIdHash];
}

@end
