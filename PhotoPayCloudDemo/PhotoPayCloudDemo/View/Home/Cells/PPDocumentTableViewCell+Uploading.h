//
//  PPDocumentTableViewCell+Uploading.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell.h"

@interface PPDocumentTableViewCell (Uploading)

- (void)refreshWithUploadingDocument:(PPLocalDocument*)uploadingDocument;

- (void)refreshProgress;

@end
