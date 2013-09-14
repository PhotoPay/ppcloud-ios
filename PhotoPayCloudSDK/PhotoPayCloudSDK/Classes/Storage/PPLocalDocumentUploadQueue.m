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

- (BOOL)front:(PPLocalDocument*)front {
    if ([self.elements count] == 0) {
        return NO; // avoid raising exception
    }
    front = [self.elements objectAtIndex:0];
    return YES;
}

- (BOOL)back:(PPLocalDocument*)back {
    if ([self.elements count] == 0) {
        return NO; // avoid raising exception
    }
    back = [self.elements objectAtIndex:[self.elements count] - 1];
    return YES;
}

- (BOOL)remove:(PPLocalDocument*)document {
    for (int i = 0; i < [elements count]; i++) {
        if ([[elements objectAtIndex:i] isEqualToDocument:document]) {
            [self.elements removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}

- (BOOL)dequeue:(PPLocalDocument*)document {
    if ([self.elements count] == 0) {
        document = nil;
        return NO;
    }
    
    document = [self.elements objectAtIndex:0];
    [self.elements removeObjectAtIndex:0];
    
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:[document ownerIdHash]]];
}

- (BOOL)enqueue:(PPLocalDocument*)document {
    [self.elements addObject:document];
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPLocalDocumentUploadQueue serializationPathForUserIdHash:[document ownerIdHash]]];
    
    return NO;
}

- (NSUInteger)count {
    return [self.elements count];
}

+ (NSString*)serializationPathForUserIdHash:(NSString*)userIdHash {
    NSError * __autoreleasing error;
    NSString* basePath = [[UIApplication applicationDocumentsDirectoryWithError:&error] path];
    
    if (basePath == nil) {
        return nil;
    }
    
    return [basePath stringByAppendingFormat:@"/%@.params", userIdHash];
}

@end
