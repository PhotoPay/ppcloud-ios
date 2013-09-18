//
//  PPDocumentTableViewCell+Uploading.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell+Uploading.h"

@implementation PPDocumentTableViewCell (Uploading)

- (void)refreshWithUploadingDocument:(PPLocalDocument*)uploadingDocument {
    [self refreshWithDocument:uploadingDocument];
    
    NSLog(@"Uploading refresh");
    
    [self largeLabel].hidden = YES;
    [self mediumLabel].hidden = NO;
    [self smallLabel].hidden = YES;
    [self progressView].hidden = NO;
    
    [self mediumLabel].text = _(@"PhotoPayHomeDocumentUploadingLabel");
    
    self.progressView.progress = [[[[uploadingDocument localDocument] uploadRequest] progress] floatValue];
}

- (void)refreshProgress {
    self.progressView.progress = [[[[[self document] localDocument] uploadRequest] progress] floatValue];
}

@end
