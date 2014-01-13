//
//  PPElementPosition.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPElementPosition.h"

@implementation PPElementPosition

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return self;
    }
    
    self.height = [PPModelObject initNumber:dictionary[@"height"]];
    self.page = [PPModelObject initNumber:dictionary[@"page"]];
    self.width = [PPModelObject initNumber:dictionary[@"width"]];
    self.x = [PPModelObject initNumber:dictionary[@"x"]];
    self.y = [PPModelObject initNumber:dictionary[@"y"]];
    
    return self;
}

- (NSString*)description {
    NSString* result = @"PPElementPosition:\n";
    result = [result stringByAppendingFormat:@"Height %d\n", [[self height] integerValue]];
    result = [result stringByAppendingFormat:@"Page %d\n", [[self page] integerValue]];
    result = [result stringByAppendingFormat:@"Width %d\n", [[self width] integerValue]];
    result = [result stringByAppendingFormat:@"X %d\n", [[self x] integerValue]];
    result = [result stringByAppendingFormat:@"Y %d\n", [[self y] integerValue]];
    return result;
}

@end
