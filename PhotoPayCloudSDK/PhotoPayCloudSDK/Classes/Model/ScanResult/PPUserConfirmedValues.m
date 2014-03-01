//
//  PPUserConfirmedValues.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/27/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues.h"

@implementation PPUserConfirmedValues

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return self;
    }
    
    self.values = [dictionary mutableCopy];
    
    return self;
}

- (NSMutableDictionary*)dictionaryWithModelObject {
    NSMutableDictionary* dictionary = [super dictionaryWithModelObject];
    
    [dictionary addEntriesFromDictionary:self.values];
    
    return dictionary;
}

- (NSString*)description {
    NSString *result = [NSString stringWithFormat:@"User confirmed data size %u\n", (unsigned int) [self.values count]];
    NSArray *keys = [self.values allKeys];
    
    for (NSString* key in keys) {
        result = [result stringByAppendingFormat:@"%@: %@\n", key, self.values[key]];
    }
    
    return result;
}

@end
