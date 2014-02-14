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
        _userId = inUserId;
        _organizationId = inOrganizationId;
        _userType = inUserType;
        _firstName = [NSString pp_UUID];
        _lastName = [NSString pp_UUID];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _userId = [decoder decodeObjectForKey:@"userID"];
        _organizationId = [decoder decodeObjectForKey:@"organizationId"];
        _userType = [decoder decodeIntegerForKey:@"userType"];
        _email = [decoder decodeObjectForKey:@"email"];
        _allEmailAddresses = [decoder decodeObjectForKey:@"allEmailAddresses"];
        _firstName = [decoder decodeObjectForKey:@"firstName"];
        _lastName = [decoder decodeObjectForKey:@"lastName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[self userId] forKey:@"userID"];
    [encoder encodeObject:[self organizationId] forKey:@"organizationId"];
    [encoder encodeInteger:[self userType] forKey:@"userType"];
    [encoder encodeObject:[self email] forKey:@"email"];
    [encoder encodeObject:[self allEmailAddresses] forKey:@"allEmailAddresses"];
    [encoder encodeObject:[self firstName] forKey:@"firstName"];
    [encoder encodeObject:[self lastName] forKey:@"lastName"];
}

- (NSString*)userIdHash {
    return [[self userId] pp_MD5];
}

- (NSString*)description {
    NSString* ret = @"User:\n";
    ret = [ret stringByAppendingFormat:@"ID: %@\n", [self userId]];
    ret = [ret stringByAppendingFormat:@"organization: %@\n", [self organizationId]];
    ret = [ret stringByAppendingFormat:@"type: %@\n", [PPUser objectForUserType:[self userType]]];
    ret = [ret stringByAppendingFormat:@"email: %@\n", [self email]];
    ret = [ret stringByAppendingFormat:@"all emails: %@\n", [self allEmailAddresses]];
    return ret;
}

+ (NSDictionary *)userTypeObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPUserTypeDefault) : @(0),
                  @(PPUserTypePerson) : @(0),
                  @(PPUserTypeBusiness) : @(1),
                  @(PPUserTypeCraft) : @(2)};
    });
    return table;
}

+ (id)objectForUserType:(PPUserType)type {
    return [PPUser userTypeObjectTable][@(type)];
}

+ (NSString*)uuid {
    return [[NSString pp_UUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
