//
//  PPDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocument.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import "UIImage+Processing.h"

@interface PPDocument ()

/**
 Creates and returns an map enum value : object value for enum PPDocumentType
 
 This is primarily used in making network requests
 */
+ (NSDictionary*)documentTypeObjectTable;

/**
 Creates and returns an map enum value : object value for enum PPDocumentProcessingType
 
 This is primarily used in making network requests
 */
+ (NSDictionary *)documentProcessingTypeObjectTable;

/**
 Creates and returns an map enum value : object value for enum PPDocumentProcessingState
 
 This is primarily used in debugging
 */
+ (NSDictionary *)documentStateObjectTable;

/** Cached thumbnail image */
@property (nonatomic, strong) UIImage* thumbnailImage;

@end

@implementation PPDocument

@synthesize url = url_;
@synthesize state;
@synthesize documentType;
@synthesize processingType;
@synthesize creationDate;
@synthesize thumbnailImage;

- (id)initWithUrl:(NSURL*)inUrl
    documentState:(PPDocumentState)inState
     documentType:(PPDocumentType)inDocumentType
   processingType:(PPDocumentProcessingType)inProcessingType {
    self = [super init];
    if (self) {
        url_ = inUrl;
        state = inState;
        documentType = inDocumentType;
        processingType = inProcessingType;
        creationDate = [NSDate date];
        thumbnailImage = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    url_ = [decoder decodeObjectForKey:@"url"];
    state = [decoder decodeIntegerForKey:@"state"];
    documentType = [decoder decodeIntegerForKey:@"documentType"];
    processingType = [decoder decodeIntegerForKey:@"processingType"];
    creationDate = [decoder decodeObjectForKey:@"creationDate"];
    thumbnailImage = nil;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeInteger:self.state forKey:@"state"];
    [encoder encodeInteger:self.documentType forKey:@"documentType"];
    [encoder encodeInteger:self.processingType forKey:@"processingType"];
    [encoder encodeObject:self.creationDate forKey:@"creationDate"];
}

- (void)setState:(PPDocumentState)inState {
    if (state != inState) {
        state = inState;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[self delegate] documentDidChangeState:self];
        });
    }
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return true;
    }
    if ([self class] != [other class]) {
        return false;
    }
    return [[[self url] path] isEqualToString:[[(PPDocument* )other url] path]];
}

- (NSUInteger)hash {
    return [[[self url] path] hash];
}

- (void)thumbnailImageWithSuccess:(void (^)(UIImage* thumbnailImage))success
                          failure:(void (^)(void))failure {
    if (failure) {
        failure();
    }
}

- (void)previewImageWithSuccess:(void (^)(UIImage* previewImage))success
                        failure:(void (^)(void))failure {
    if (failure) {
        failure();
    }
}

- (NSString*)mimeType {
    switch ([self documentType]) {
        case PPDocumentTypePNG:
            return @"image/png";
            break;
        case PPDocumentTypeJPG:
            return @"image/jpeg";
            break;
        case PPDocumentTypeGIF:
            return @"image/gif";
            break;
        case PPDocumentTypeTIFF:
            return @"image/tiff";
            break;
        case PPDocumentTypePDF:
            return @"application/pdf";
            break;
        case PPDocumentTypeHTML:
            return @"text/html";
            break;
        case PPDocumentTypeXLS:
            return @"application/excel";
            break;
        case PPDocumentTypeDOC:
            return @"application/msword";
            break;
        case PPDocumentTypeTXT:
            return @"text/plain";
            break;
        case PPDocumentTypeXML:
            return @"text/xml";
            break;
        case PPDocumentTypeJSON:
            return @"application/json";
            break;
        default:
            // invalid document type
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"%u is not a valid document type", [self documentType]]
                                         userInfo:nil];
            break;
    }
}

- (PPLocalDocument*)localDocument {
    if ((([self state] & PPDocumentStateLocal) != 0) && [self isKindOfClass:[PPLocalDocument class]]) {
        return (PPLocalDocument*) self;
    } else {
        return nil;
    }
}

- (PPRemoteDocument*)remoteDocument {
    if ((([self state] & PPDocumentStateLocal) == 0) && [self isKindOfClass:[PPLocalDocument class]]) {
        return (PPRemoteDocument*) self;
    } else {
        return nil;
    }
}

- (NSString*)description {
    NSString* result = @"";
    result = [result stringByAppendingFormat:@"Document URL: %@\n", [[self url] path]];
    result = [result stringByAppendingFormat:@"State: %@\n", [PPDocument objectForDocumentState:[self state]]];
    result = [result stringByAppendingFormat:@"Type: %@\n", [PPDocument objectForDocumentType:[self documentType]]];
    result = [result stringByAppendingFormat:@"Processing Type: %@\n", [PPDocument objectForDocumentProcessingType:[self processingType]]];
    result = [result stringByAppendingFormat:@"Creation Date: %@\n", [[self creationDate] description]];
    return result;
}

+ (NSDictionary *)documentTypeObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPDocumentTypeDOC) : @"DOC",
                  @(PPDocumentTypeGIF) : @"GIF",
                  @(PPDocumentTypeHTML) : @"HTML",
                  @(PPDocumentTypeJPG) : @"JPEG",
                  @(PPDocumentTypeJSON) : @"JSON",
                  @(PPDocumentTypePDF) : @"PDF",
                  @(PPDocumentTypePNG) : @"PNG",
                  @(PPDocumentTypeTIFF) : @"TIFF",
                  @(PPDocumentTypeTXT) : @"TXT",
                  @(PPDocumentTypeXLS) : @"XLS",
                  @(PPDocumentTypeXML) : @"XML"};
    });
    return table;
}

+ (id)objectForDocumentType:(PPDocumentType)documentType {
    return [PPDocument documentTypeObjectTable][@(documentType)];
}

+ (NSDictionary *)documentStateObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPDocumentStatePaid)                : @"Paid",
                  @(PPDocumentStateCreated)             : @"Created",
                  @(PPDocumentStateDeleted)             : @"Deleted",
                  @(PPDocumentStatePending)             : @"Pending",
                  @(PPDocumentStateProcessed)           : @"Processed",
                  @(PPDocumentStateProcessedWithError)  : @"ProcessedWithError",
                  @(PPDocumentStateProcessing)          : @"Processing",
                  @(PPDocumentStateProcessingError)     : @"ProcessingError",
                  @(PPDocumentStateReceived)            : @"Received",
                  @(PPDocumentStateStored)              : @"Stored",
                  @(PPDocumentStateUnknown)             : @"Unknown",
                  @(PPDocumentStateUploading)           : @"Uploading",
                  @(PPDocumentStateUploadFailed)        : @"UploadFailed"};
    });
    return table;
}

+ (id)objectForDocumentState:(PPDocumentState)documentState {
    return [PPDocument documentStateObjectTable][@(documentState)];
}

+ (NSDictionary *)documentProcessingTypeObjectTable {
    return @{@(PPDocumentProcessingTypeAustrianPDFInvoice)      : @"RequestType_Austria_PDF",
             @(PPDocumentProcessingTypeAustrianPhotoInvoice)    : @"RequestType_Austria",
             @(PPDocumentProcessingTypeSerbianPDFInvoice)       : @"RequestType_Serbia_PDF",
             @(PPDocumentProcessingTypeSerbianPhotoInvoice)     : @"RequestType_Serbia"};
}

+ (id)objectForDocumentProcessingType:(PPDocumentProcessingType)type {
    return [PPDocument documentProcessingTypeObjectTable][@(type)];
}

@end
