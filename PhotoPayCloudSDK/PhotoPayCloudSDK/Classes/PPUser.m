//
//  PPUser.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/9/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPUser.h"
#import "NSString+Factory.h"

@interface PPUser ()

+ (NSDictionary *)userTypeObjectTable;

@end

@implementation PPUser

@synthesize userId;
@synthesize organizationId;
@synthesize userType;

- (id)initWithUserId:(NSString*)inUserId
      organizationId:(NSString*)inOrganizationId {
    return [self initWithUserId:inUserId
                 organizationId:inOrganizationId
                       userType:PPUserTypeDefault];
}

- (id)initWithUserId:(NSString*)inUserId
      organizationId:(NSString*)inOrganizationId
            userType:(PPUserType)inUserType {
    self = [super init];
    if (self) {
        userId = inUserId;
        organizationId = inOrganizationId;
        userType = inUserType;
    }
    return self;
}

- (NSString*)userIdHash {
    return [[self userId] MD5];
}

+ (NSDictionary *)userTypeObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPUserTypeDefault) : @"Default",
                  @(PPUserTypePerson) : @"Person",
                  @(PPUserTypeBusiness) : @"Business",
                  @(PPUserTypeCraft) : @"Craft"};
    });
    return table;
}

+ (id)objectForUserType:(PPUserType)type {
    return [PPUser userTypeObjectTable][@(type)];
}

@end
