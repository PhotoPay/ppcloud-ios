//
//  PPDocument.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocument.h"

@interface PPDocument ()

+ (NSDictionary*)documentTypeObjectTable;

@end

@implementation PPDocument

@synthesize url = url_;
@synthesize state;

- (id)initWithUrl:(NSURL*)inUrl
    documentState:(PPDocumentState)inState {
    self = [super init];
    if (self) {
        url_ = inUrl;
        state = inState;
    }
    return self;
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

@end
