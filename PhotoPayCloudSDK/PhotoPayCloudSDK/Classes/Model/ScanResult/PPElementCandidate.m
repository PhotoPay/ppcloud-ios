//
//  PPElementCandidate.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPElementCandidate.h"
#import "PPElementPosition.h"

@implementation PPElementCandidate

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    self.confidence = [PPModelObject initNumber:dictionary[@"confidence"]];
    self.position = [[PPElementPosition alloc] initWithDictionary:dictionary[@"position"]];
    self.value = [PPModelObject initString:dictionary[@"value"]];
    
    return self;
}

- (NSString*)description {
    NSString* result = @"PPElementCandidate:\n";
    result = [result stringByAppendingFormat:@"Value: %@\n", [self value]];
    result = [result stringByAppendingFormat:@"Confidence: %@\n", [self confidence]];
    result = [result stringByAppendingFormat:@"Position: %@\n", [self position]];
    return result;
}

@end
