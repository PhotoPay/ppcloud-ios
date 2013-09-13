//
//  PPUploadParametersQueue.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPUploadParametersQueue.h"

@implementation PPUploadParametersQueue

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
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[PPUploadParameters serializationPathForUserIdHash:userIdHash]];
}

- (BOOL)front:(PPUploadParameters*)front {
    if ([self.elements count] == 0) {
        return NO; // avoid raising exception
    }
    front = [self.elements objectAtIndex:0];
    return YES;
}

- (BOOL)back:(PPUploadParameters*)back {
    if ([self.elements count] == 0) {
        return NO; // avoid raising exception
    }
    back = [self.elements objectAtIndex:[self.elements count] - 1];
    return YES;
}

- (BOOL)remove:(PPUploadParameters*)parameters {
    for (int i = 0; i < [elements count]; i++) {
        if ([[elements objectAtIndex:i] isEqual:parameters]) {
            [self.elements removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}

- (BOOL)dequeue:(PPUploadParameters*)front {
    if ([self.elements count] == 0) {
        front = nil;
        return NO;
    }
    
    front = [self.elements objectAtIndex:0];
    [self.elements removeObjectAtIndex:0];
    
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPUploadParameters serializationPathForUserIdHash:[front userIdHash]]];
}

- (BOOL)enqueue:(PPUploadParameters*)parameters {
    NSLog(@"Enqueueing");
    [self.elements addObject:parameters];
    NSLog(@"Saving");
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[PPUploadParameters serializationPathForUserIdHash:[parameters userIdHash]]];
    
    return NO;
}

- (NSUInteger)count {
    return [self.elements count];
}

@end
