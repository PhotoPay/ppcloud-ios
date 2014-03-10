//
//  PPProfile.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 21/02/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPProfile.h"
#import "PPEBSProfile.h"

@implementation PPProfile

+ (PPProfile*)sharedProfile {
    static PPProfile* sharedProfile = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProfile = [[PPEBSProfile alloc] init];
    });
    
    return sharedProfile;
}

- (NSString*)language {
    return @"en";
}

- (NSString*)processingServer {
    return @"http://cloudbeta.photopay.net/";
}

- (NSString*)organizationName {
    return @"PhotoPay";
}

- (NSString*)appName {
    return @"PhotoPayCloudDemo";
}

- (NSString*)distributionUrl {
    return @"http://demo.photopay.net/distribute/iphone/cloud/";
}

- (PPDocumentProcessingType)pdfProcessingType {
    return PPDocumentProcessingTypeAustrianPDFInvoice;
}

- (PPDocumentProcessingType)photoProcessingType {
    return PPDocumentProcessingTypeSerbianPhotoInvoice;
}

@end
