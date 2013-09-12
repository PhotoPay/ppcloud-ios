//
//  PPUploadParameters.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/9/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPUser.h"
#import "PPLocalDocument.h"
#import "PPPhotoPayCloudService.h"

/**
 Metadata which describes each upload request
 */
@interface PPUploadParameters : NSObject <NSCoding>

/** URL to local document */
@property (nonatomic, strong,) NSURL* localDocumentUrl;

/** Type of the document which is to be uploaded */
@property (nonatomic) PPDocumentType localDocumentType;

/** Type of the request to be sent */
@property (nonatomic) PPDocumentProcessingType processingType;

/** Hashed value of user ID */
@property (nonatomic, strong) NSString* userIdHash;

/** Id of the organization the user belongs to */
@property (nonatomic, strong) NSString* organizationId;

/** Type of the user */
@property (nonatomic) PPUserType userType;

/** True if push notification needs to be sent */
@property (nonatomic) BOOL pushNotify;

/** Device token for push notifications */
@property (nonatomic) NSData* deviceToken;

/** Exact date time when request was created */
@property (nonatomic) NSDate* creationDate;

/**
 Helper method for debugging.
 
 Retrieves a string representation of the object
 */
- (NSString*)toString;

+ (NSString*)serializationPathForUserIdHash:(NSString*)userIdHash;

@end
