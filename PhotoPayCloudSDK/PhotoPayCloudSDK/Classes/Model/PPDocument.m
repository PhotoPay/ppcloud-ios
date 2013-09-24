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
 Creates and returns an map enum value : file extension name for enum PPDocumentType
 
 This is primarily used for saving documents in the right format
 */
+ (NSDictionary*)fileExtensionTable;

/** Cached thumbnail image */
@property (nonatomic, strong) UIImage* thumbnailImage;

@end

@implementation PPDocument

@synthesize documentId = documentId_;
@synthesize bytesUrl;
@synthesize state;
@synthesize documentType = documentType_;
@synthesize processingType = processingType_;
@synthesize creationDate = creationDate_;
@synthesize thumbnailImage;

- (id)initWithDocumentId:(NSString*)inDocumentId
                bytesUrl:(NSURL*)inBytesUrl
           documentState:(PPDocumentState)inState
            documentType:(PPDocumentType)inDocumentType
          processingType:(PPDocumentProcessingType)inProcessingType {
    self = [super init];
    if (self) {
        if (inDocumentId == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Document ID should not be nil!"
                                         userInfo:nil];
        }
        documentId_ = inDocumentId;
        bytesUrl = inBytesUrl;
        state = inState;
        documentType_ = inDocumentType;
        processingType_ = inProcessingType;
        creationDate_ = [NSDate date];
        thumbnailImage = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    documentId_ = [decoder decodeObjectForKey:@"documentId"];
    bytesUrl = [decoder decodeObjectForKey:@"bytesUrl"];
    state = [decoder decodeIntegerForKey:@"state"];
    documentType_ = [decoder decodeIntegerForKey:@"documentType"];
    processingType_ = [decoder decodeIntegerForKey:@"processingType"];
    creationDate_ = [decoder decodeObjectForKey:@"creationDate"];
    thumbnailImage = nil;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.documentId forKey:@"documentId"];
    [encoder encodeObject:self.bytesUrl forKey:@"bytesUrl"];
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
    return [[self documentId] isEqualToString:[(PPDocument* )other documentId]];
}

- (NSUInteger)hash {
    return [[self documentId] hash];
}

- (void)thumbnailImageWithSuccess:(void (^)(UIImage* thumbnailImage))success
                          failure:(void (^)(void))failure {
    dispatch_async(dispatch_get_main_queue(), ^(){
        if (failure) {
            failure();
        }
    });
}

- (void)previewImageWithSuccess:(void (^)(UIImage* previewImage))success
                        failure:(void (^)(void))failure {
    dispatch_async(dispatch_get_main_queue(), ^(){
        if (failure) {
            failure();
        }
    });
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
    if ((([self state] & PPDocumentStateLocal) == 0) && [self isKindOfClass:[PPRemoteDocument class]]) {
        return (PPRemoteDocument*) self;
    } else {
        return nil;
    }
}

- (BOOL)reloadWithDocument:(PPDocument*)other {
    return NO;
}

- (NSString*)description {
    NSString* result = @"";
    result = [result stringByAppendingFormat:@"Document ID: %@\n", [self documentId]];
    result = [result stringByAppendingFormat:@"Document bytes URL: %@\n", [self bytesUrl]];
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
        table = @{@(PPDocumentStatePaid)                : @"RESULTS_ACK",
                  @(PPDocumentStateCreated)             : @"CREATED",
                  @(PPDocumentStateDeleted)             : @"USER_DELETED",
                  @(PPDocumentStatePending)             : @"PENDING",
                  @(PPDocumentStateProcessed)           : @"DONE",
                  @(PPDocumentStateProcessedWithError)  : @"FORCED_ERROR",
                  @(PPDocumentStateProcessing)          : @"WIP",
                  @(PPDocumentStateProcessingError)     : @"ERROR",
                  @(PPDocumentStateReceived)            : @"NEW",
                  @(PPDocumentStateStored)              : @"STORED",
                  @(PPDocumentStateUnknown)             : @"UNKNOWN",
                  @(PPDocumentStateUploading)           : @"UPLOADING",
                  @(PPDocumentStateUploadFailed)        : @"UPLOAD_FAILED"};
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

+ (NSDictionary *)fileExtensionTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPDocumentTypeDOC) : @"doc",
                  @(PPDocumentTypeGIF) : @"gif",
                  @(PPDocumentTypeHTML) : @"html",
                  @(PPDocumentTypeJPG) : @"jpg",
                  @(PPDocumentTypeJSON) : @"json",
                  @(PPDocumentTypePDF) : @"pdf",
                  @(PPDocumentTypePNG) : @"png",
                  @(PPDocumentTypeTIFF) : @"tiff",
                  @(PPDocumentTypeTXT) : @"txt",
                  @(PPDocumentTypeXLS) : @"xls",
                  @(PPDocumentTypeXML) : @"xml"};
    });
    return table;
}

/**
 Returns file extension string for a given document type
 */
+ (id)fileExtensionForDocumentType:(PPDocumentType)documentType {
    return [PPDocument fileExtensionTable][@(documentType)];
}

@end
