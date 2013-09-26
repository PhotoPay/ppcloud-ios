//
//  PPDocumentPreview.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@class PPDocument;

@interface PPDocumentPreview : NSObject<QLPreviewControllerDataSource, QLPreviewItem>

- (id)initWithDocument:(PPDocument*)document
         forController:(QLPreviewController*)qlController;

@property (nonatomic, strong) PPDocument* document;

@end
