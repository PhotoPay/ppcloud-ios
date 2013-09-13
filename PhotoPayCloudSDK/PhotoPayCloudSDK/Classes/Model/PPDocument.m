//
//  PPDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocument.h"
#import "PPLocalDocument.h"

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
+ (NSDictionary*)documentProcessingTypeObjectTable;

@end

@implementation PPDocument

@synthesize url = url_;
@synthesize state;
@synthesize documentType;
@synthesize processingType;

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
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeInteger:self.state forKey:@"state"];
    [encoder encodeInteger:self.documentType forKey:@"documentType"];
    [encoder encodeInteger:self.processingType forKey:@"processingType"];
}

- (BOOL)isEqualToDocument:(id)other {
    if (self == other) {
        return true;
    }
    if ([self class] != [other class]) {
        return false;
    }
    return [[[self url] path] isEqualToString:[[(PPDocument* )other url] path]];
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

- (NSString*)toString {
    NSString* result = @"";
    
    result = [result stringByAppendingFormat:@"Local document url: %@\n", [[self url] path]];

    result = [result stringByAppendingFormat:@"Local document type: %@\n", [PPDocument objectForDocumentType:[self documentType]]];

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
    
    return result;
}


+ (NSDictionary *)documentTypeObjectTable {
    static NSDictionary *table = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        table = @{@(PPDocumentTypeDOC) : @"DOC",
                  @(PPDocumentTypeGIF) : @"GIF",
                  @(PPDocumentTypeHTML) : @"HTML",
                  @(PPDocumentTypeJPG) : @"JPG",
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

+ (NSDictionary *)documentProcessingTypeObjectTable {
    return @{@(PPDocumentProcessingTypeAustrianPDFInvoice)      : @"AustrianPDF",
             @(PPDocumentProcessingTypeAustrianPhotoInvoice)    : @"AustrianPhoto",
             @(PPDocumentProcessingTypeSerbianPDFInvoice)       : @"SerbianPDF",
             @(PPDocumentProcessingTypeSerbianPhotoInvoice)     : @"SerbianPhoto"};
}

+ (id)objectForDocumentProcessingType:(PPDocumentProcessingType)type {
    return [PPDocument documentProcessingTypeObjectTable][@(type)];
}

@end
