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
    
    self.errorCode = [PPModelObject initNumber:dictionary[@"errorCode"] defaultNumber:0].intValue;
    self.errorMessage = [PPModelObject initString:dictionary[@"errorMessage"]];
    self.totalCount = [PPModelObject initNumber:dictionary[@"totalCount"] defaultNumber:0];
    self.documentsList = [PPModelObject initArray:dictionary[@"documentList"] className:NSStringFromClass([PPRemoteDocument class])];
    self.document = [[PPRemoteDocument alloc] initWithDictionary:dictionary[@"document"]];
    
    return self;
};

- (NSString*)description {
    NSString* ret = @"Base response:\n";
    
    if (self.errorCode > 0) {
        ret = [ret stringByAppendingFormat:@"errorCode %d\n", (int) self.errorCode];
    }
    if (self.errorMessage != nil) {
        ret = [ret stringByAppendingFormat:@"errorMessage %@\n", self.errorMessage];
    }
    if (self.totalCount.intValue > 0) {
        ret = [ret stringByAppendingFormat:@"totalCount %d\n", self.totalCount.intValue];
    }
    if (self.documentsList != nil) {
        ret = [ret stringByAppendingFormat:@"documentsList %@\n", self.documentsList];
    }
    if (self.document != nil) {
        ret = [ret stringByAppendingFormat:@"document %@\n", self.document];
    }
    
    return ret;
}

@end
