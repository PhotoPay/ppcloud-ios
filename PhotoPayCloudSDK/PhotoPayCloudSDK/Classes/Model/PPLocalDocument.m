//
//  PPLocalDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalDocument.h"
#import "PPDocumentManager.h"
#import "NSString+Factory.h"

@implementation PPLocalDocument

@synthesize bytes = bytes_;
@synthesize type;

- (id)initWithBytes:(NSData*)inBytes
               type:(PPDocumentType)inType {
    self = [super initWithUrl:nil documentState:PPDocumentStateCreated];
    if (self) {
        bytes_ = inBytes;
        type = inType;
    }
    return self;
}

- (void)saveUsingDocumentManager:(PPDocumentManager*)documentManager
                         success:(void(^)(NSURL* documentUrl))success
                         failure:(void(^)(NSError* error))failure {
    
    [documentManager saveDocument:self
                          success:^(PPLocalDocument*localDocument, NSURL* documentUrl) {
                              self->url_ = documentUrl;
                              success(documentUrl);
                          }
                          failure:^(PPLocalDocument*localDocument, NSError* error) {
                              failure(error);
                          }];
}

+ (NSString*)generateUniqueFilenameForType:(PPDocumentType)type {
    NSString* uuid = [NSString UUID];
    NSString* extension = [PPLocalDocument extensionForDocumentType:type];
    return [NSString stringWithFormat:@"%@.%@", uuid, extension];
}

+ (NSString*)extensionForDocumentType:(PPDocumentType)type {
    switch (type) {
        case PPDocumentTypePNG:
            return @"png";
            break;
        case PPDocumentTypeJPG:
            return @"jpg";
            break;
        case PPDocumentTypeGIF:
            return @"gif";
            break;
        case PPDocumentTypeTIFF:
            return @"tiff";
            break;
        case PPDocumentTypePDF:
            return @"pdf";
            break;
        case PPDocumentTypeHTML:
            return @"html";
            break;
        case PPDocumentTypeXLS:
            return @"xls";
            break;
        case PPDocumentTypeDOC:
            return @"doc";
            break;
        case PPDocumentTypeTXT:
            return @"txt";
            break;
        case PPDocumentTypeXML:
            return @"xml";
            break;
        case PPDocumentTypeJSON:
            return @"json";
            break;
        default:
            return @"invalidFilename";
            break;
    }
}

@end
