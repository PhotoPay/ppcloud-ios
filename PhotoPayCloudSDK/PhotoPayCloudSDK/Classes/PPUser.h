//
//  PPUser.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/9/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Encapsulates all data PhotoPay Cloud service needs for a certain user
 */
@interface PPUser : NSObject <NSCoding>

/**
 All possible user types.
 
 Required because users with different types can have the same ID
*/
typedef NS_ENUM(NSUInteger, PPUserType) {
    PPUserTypeDefault, // server default will be used, which is typically person type
    PPUserTypePerson,
    PPUserTypeBusiness,
    PPUserTypeCraft
};

/** Id of the user */
@property (nonatomic, strong, readonly) NSString* userId;

/** Id of the organization the user belongs to */
@property (nonatomic, strong, readonly) NSString* organizationId;

/** Type of the user */
@property (nonatomic, readonly) PPUserType userType;

/** Main email address for the user */
@property (nonatomic, strong) NSString* email;

/** All email adresses used by the user */
@property (nonatomic, strong) NSMutableSet* allEmailAddresses;

/** First name of the user */
@property (nonatomic, strong) NSString* firstName;

/** Last name of the user */
@property (nonatomic, strong) NSString* lastName;

/**
 Initializer.
 
 Sets user type to default value PPUserTypePerson
 */
- (id)initWithUserId:(NSString*)userId
      organizationId:(NSString*)organizationId;

/** 
 Designated initializer
 
 Sets all user's properties
 */
- (id)initWithUserId:(NSString*)userId
      organizationId:(NSString*)organizationId
            userType:(PPUserType)userType;

/**
 Returns the hashed value of the user ID
 */
- (NSString*)userIdHash;

/**
 Description of user object
 */
- (NSString*)description;

/**
 Returns object representation of the user type enum value
 */
+ (id)objectForUserType:(PPUserType)type;

/** Generates a random UID for a user */
+ (NSString*)uuid;

@end
