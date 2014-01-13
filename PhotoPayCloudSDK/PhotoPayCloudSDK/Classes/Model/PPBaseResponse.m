//
//  PPBaseResponse.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/23/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPBaseResponse.h"
#import "PPRemoteDocument.h"

@implementation PPBaseResponse

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) {
        return nil;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return self;
    }
    
    self.totalCount = [PPModelObject initNumber:dictionary[@"totalCount"] defaultNumber:0];
    self.documentsList = [PPModelObject initArray:dictionary[@"documentList"] className:NSStringFromClass([PPRemoteDocument class])];
    self.document = [[PPRemoteDocument alloc] initWithDictionary:dictionary[@"document"]];
    
    return self;
};

@end
