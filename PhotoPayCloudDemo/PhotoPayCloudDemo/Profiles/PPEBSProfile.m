//
//  PPEBSProfile.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 10/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPEBSProfile.h"

@implementation PPEBSProfile

- (NSString*)language {
    return @"hr";
}

- (NSString*)processingServer {
    return @"https://smartphonembankinguat.erstebank.rs:1027/";
}

- (NSString*)organizationName {
    return @"EBS";
}

- (NSString*)appName {
    return @"PhotoPayCloudDemo";
}

- (NSString*)distributionUrl {
    return @"http://demo.photopay.net/distribute/iphone/srb-erste-cloud/";
}

- (PPDocumentProcessingType)pdfProcessingType {
    return PPDocumentProcessingTypeSerbianPDFInvoice;
}

- (PPDocumentProcessingType)photoProcessingType {
    return PPDocumentProcessingTypeSerbianPhotoInvoice;
}

@end
