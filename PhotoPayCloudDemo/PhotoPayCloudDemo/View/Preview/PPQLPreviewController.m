//
//  PPQLPreviewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPQLPreviewController.h"
#import "PPDocumentPreview.h"

@implementation PPQLPreviewController

@synthesize documentPreview;

- (void)setDocumentPreview:(PPDocumentPreview *)inDocumentPreview {
    documentPreview = inDocumentPreview;
    self.dataSource = inDocumentPreview;
}

@end
