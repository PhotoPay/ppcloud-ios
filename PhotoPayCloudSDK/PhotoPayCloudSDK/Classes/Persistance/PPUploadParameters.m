//
//  PPUploadMetadata.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/9/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPUploadParameters.h"
#import "UIApplication+Documents.h"

@implementation PPUploadParameters

@synthesize localDocument;
@synthesize userIdHash;
@synthesize organizationId;
@synthesize userType;
@synthesize pushNotify;
@synthesize deviceToken;
@synthesize creationDate;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    localDocument = [decoder decodeObjectForKey:@"localDocument"];
    userIdHash = [decoder decodeObjectForKey:@"userIdHash"];
    organizationId = [decoder decodeObjectForKey:@"organizationId"];
    userType = [decoder decodeIntegerForKey:@"userType"];
    pushNotify = [decoder decodeBoolForKey:@"pushNotify"];
    deviceToken = [decoder decodeObjectForKey:@"deviceToken"];
    creationDate = [decoder decodeObjectForKey:@"creationDate"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.localDocument forKey:@"localDocument"];
    [encoder encodeObject:self.userIdHash forKey:@"userIdHash"];
    [encoder encodeObject:self.organizationId forKey:@"organizationId"];
    [encoder encodeInteger:self.userType forKey:@"userType"];
    [encoder encodeBool:self.pushNotify forKey:@"pushNotify"];
    [encoder encodeObject:self.deviceToken forKey:@"deviceToken"];
    [encoder encodeObject:self.creationDate forKey:@"creationDate"];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        // isEqual is good enough for our purpose
        return [[self localDocument] isEqualToDocument:[object localDocument]];
    } else {
        return false;
    }
}

- (NSUInteger)hash {
    return [[self localDocument] hash];
}

- (NSString*)toString {
    NSString *result = @"";
    
    if (self.localDocument != nil) {
        result = [result stringByAppendingFormat:@"Local document url: %@\n", [[self localDocument] toString]];
    }
    
    if (self.userIdHash != nil) {
        result = [result stringByAppendingFormat:@"User id hash: %@\n", [self userIdHash]];
    }
    
    if (self.organizationId != nil) {
        result = [result stringByAppendingFormat:@"Organization ID: %@\n", [self organizationId]];
    }
    
    switch ([self userType]) {
        case PPUserTypePerson:
            result = [result stringByAppendingString:@"User type: person\n"];
            break;
        case PPUserTypeBusiness:
            result = [result stringByAppendingString:@"User type: business\n"];
            break;
        case PPUserTypeCraft:
            result = [result stringByAppendingString:@"User type: craft\n"];
            break;
        default:
            result = [result stringByAppendingString:@"User type: person\n"];
            break;
    }
    
    if ([self pushNotify]) {
        result = [result stringByAppendingString:@"Push notify: YES\n"];
    } else {
        result = [result stringByAppendingString:@"Push notify: NO\n"];
    }
    
    if ([self deviceToken]) {
        result = [result stringByAppendingFormat:@"Device token: %@\n", [self deviceToken]];
    }
    
    if ([self creationDate]) {
        NSString *dateStr = [NSDateFormatter localizedStringFromDate:[self creationDate]
                                                           dateStyle:NSDateFormatterShortStyle
                                                           timeStyle:NSDateFormatterFullStyle];
        result = [result stringByAppendingFormat:@"Creation date: %@\n", dateStr];
    }
    
    return result;
}

+ (NSString*)serializationPathForUserIdHash:(NSString*)userIdHash {
    NSError * __autoreleasing error;
    NSString* basePath = [[UIApplication applicationDocumentsDirectoryWithError:&error] path];
    
    if (basePath == nil) {
        return nil;
    }
    
    return [basePath stringByAppendingFormat:@"/%@.params", userIdHash];
}

@end
