//
//  PPQLPreviewController.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@class PPDocumentPreview;

@interface PPQLPreviewController : QLPreviewController

@property (nonatomic, strong) PPDocumentPreview* documentPreview;

@end
