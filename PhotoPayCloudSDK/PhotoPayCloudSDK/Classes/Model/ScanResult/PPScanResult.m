//
//  PPScanResult.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"
#import "PPElementCandidateList.h"
#import "PPElementCandidate.h"

@implementation PPScanResult

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return self;
    }
    
    self.documentType = [PPModelObject initString:dictionary[@"document"]];
    
    NSDictionary* dictionaryElements = dictionary[@"elements"];
    if (![dictionaryElements isEqual:[NSNull null]]) {
        NSArray* keys = [dictionaryElements allKeys];
    
        NSMutableDictionary *newElements = [[NSMutableDictionary alloc] init];
    
        for (NSString *key in keys) {
            PPElementCandidateList* list = [[PPElementCandidateList alloc] initWithDictionary:dictionaryElements[key]];
            [newElements setObject:list forKey:key];
        }
    
        self.elements = newElements;
    }
    
    return self;
}

- (NSString*)description {
    NSString* result = @"PPScanResult:\n";
    result = [result stringByAppendingFormat:@"Type: %@\n", [self documentType]];
    
    NSArray* keys = [[self elements] allKeys];
    for (NSString *key in keys) {
        result = [result stringByAppendingFormat:@"Key %@\n%@\n", key, [self elements][key]];
    }
    return result;
}

- (PPElementCandidateList*)candidateListForKey:(NSString*)key {
    return [self elements][key];
}

- (PPElementCandidate*)mostProbableCandidateForKey:(NSString*)key {
    PPElementCandidateList* list = [self candidateListForKey:key];
    if (list == nil || [list count] == 0) {
        return nil;
    }
    id object = [[list candidates] objectAtIndex:0];
    if (![object isKindOfClass:[PPElementCandidate class]]) {
        return nil;
    }

    return (PPElementCandidate*)object;
}

- (BOOL)isEmpty {
    return ([[self elements] count] == 0);
}

@end
