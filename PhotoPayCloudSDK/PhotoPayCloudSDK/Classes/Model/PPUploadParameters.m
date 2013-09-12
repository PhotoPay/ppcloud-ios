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

@synthesize localDocumentUrl;
@synthesize localDocumentType;
@synthesize userIdHash;
@synthesize organizationId;
@synthesize userType;
@synthesize processingType;
@synthesize pushNotify;
@synthesize deviceToken;
@synthesize creationDate;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    localDocumentUrl = [decoder decodeObjectForKey:@"localDocumentUrl"];
    localDocumentType = [decoder decodeIntegerForKey:@"localDocumentType"];
    userIdHash = [decoder decodeObjectForKey:@"userIdHash"];
    organizationId = [decoder decodeObjectForKey:@"organizationId"];
    userType = [decoder decodeIntegerForKey:@"userType"];
    processingType = [decoder decodeIntegerForKey:@"processingType"];
    pushNotify = [decoder decodeBoolForKey:@"pushNotify"];
    deviceToken = [decoder decodeObjectForKey:@"deviceToken"];
    creationDate = [decoder decodeObjectForKey:@"creationDate"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.localDocumentUrl forKey:@"localDocumentUrl"];
    [encoder encodeInteger:self.localDocumentType forKey:@"localDocumentType"];
    [encoder encodeObject:self.userIdHash forKey:@"userIdHash"];
    [encoder encodeObject:self.organizationId forKey:@"organizationId"];
    [encoder encodeInteger:self.userType forKey:@"userType"];
    [encoder encodeInteger:self.processingType forKey:@"processingType"];
    [encoder encodeBool:self.pushNotify forKey:@"pushNotify"];
    [encoder encodeObject:self.deviceToken forKey:@"deviceToken"];
    [encoder encodeObject:self.creationDate forKey:@"creationDate"];
}

- (NSString*)toString {
    NSString *result = @"";
    
    if (self.localDocumentUrl != nil) {
        result = [result stringByAppendingFormat:@"Local document url: %@\n", [self localDocumentUrl]];
    }
    
    result = [result stringByAppendingFormat:@"Local document type: %@\n", [PPLocalDocument extensionForDocumentType:[self localDocumentType]]];
    
    switch ([self processingType]) {
        case PPDocumentProcessingTypeAustrianPDFInvoice:
            result = [result stringByAppendingString:@"Processing type: Austrian PDF\n"];
            break;
        case PPDocumentProcessingTypeAustrianPhotoInvoice:
            result = [result stringByAppendingString:@"Processing type: Austrian Photo Invoice\n"];
            break;
        case PPDocumentProcessingTypeSerbianPDFInvoice:
            result = [result stringByAppendingString:@"Processing type: Serbian PDF\n"];
            break;
        case PPDocumentProcessingTypeSerbianPhotoInvoice:
        default:
            result = [result stringByAppendingString:@"Processing type: Serbian Photo Invoice\n"];
            break;
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
