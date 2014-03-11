//
//  PPTelenorProfile.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 11/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPTelenorProfile.h"

@implementation PPTelenorProfile

- (NSString*)language {
    return @"hr";
}

- (NSString*)organizationName {
    return @"Telenor";
}

- (NSString*)appName {
    return @"PhotoPayCloudDemo";
}

- (NSString*)distributionUrl {
    return @"http://demo.photopay.net/distribute/iphone/cloud-srb-telenor/";
}

- (PPDocumentProcessingType)pdfProcessingType {
    return PPDocumentProcessingTypeSerbianPDFInvoice;
}

- (PPDocumentProcessingType)photoProcessingType {
    return PPDocumentProcessingTypeSerbianPhotoInvoice;
}

@end
