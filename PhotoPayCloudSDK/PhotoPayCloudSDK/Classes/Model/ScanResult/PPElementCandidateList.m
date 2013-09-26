//
//  PPElementCandidateList.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPElementCandidateList.h"
#import "PPElementCandidate.h"

@implementation PPElementCandidateList

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *element in dictionary) {
        [array addObject:[[PPElementCandidate alloc] initWithDictionary:element]];
    }
    
    self.candidates = array;
    
    return self;
}

- (NSString*)description {
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"PPElementCandidateList length %d:\n", [[self candidates] count]];
    
    for (id object in self.candidates) {
        result = [result stringByAppendingFormat:@"%@", object];
    }
    
    return result;
}

- (NSUInteger)count {
    return [self.candidates count];
}

@end
