//
//  PPProfile.h
//  PhotoPayCloudDemo
//
//  Created by Jura on 21/02/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotoPayCloud/PhotoPayCloud.h>

@interface PPProfile : NSObject

+ (PPProfile*)sharedProfile;

- (NSString*)language;

- (NSString*)processingServer;

- (NSString*)organizationName;

- (NSString*)appName;

- (NSString*)distributionUrl;

- (PPDocumentProcessingType)pdfProcessingType;

- (PPDocumentProcessingType)photoProcessingType;

@end