//
//  PPDocumentPreview.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentPreview.h"
#import <PhotoPayCloud/PhotoPayCloud.h>

@implementation PPDocumentPreview

@synthesize document;

- (id)initWithDocument:(PPDocument*)inDocument
         forController:(QLPreviewController*)qlController {
    self = [super init];
    if (self) {
        document = inDocument;
        
        // fetch the document bytes and create a temporary file for quick look view controller
        [document documentBytesWithSuccess:^(NSData *bytes) {
            NSError * __autoreleasing error = nil;
            
            // use [[self document] qlPreviewUrl] as an url for documents for safe naming.
            [UIApplication pp_createFileWithData:bytes
                                             url:[[self document] qlPreviewUrl]
                                           error:&error];
            
            if ([qlController currentPreviewItem] == self) {
                [qlController reloadData];
                [qlController refreshCurrentPreviewItem];
            }

        } failure:nil];
    }
    return self;
}

- (void)dealloc {
    [UIApplication pp_deleteFileWithUrl:[[self document] qlPreviewUrl]
                                  error:nil];
}

#pragma mark - QLPreviewItem

- (NSURL *)previewItemURL {
    return [[self document] qlPreviewUrl];
}

- (NSString *)previewItemTitle {
    switch ([[self document] documentType]) {
        case PPDocumentTypePDF:
            return _(@"PhotoPayPreviewDocumentTitlePdf");
            break;
        case PPDocumentTypeGIF:
        case PPDocumentTypePNG:
        case PPDocumentTypeJPG:
        case PPDocumentTypeTIFF:
            return _(@"PhotoPayPreviewDocumentTitleImage");
            break;
        default:
            return _(@"PhotoPayPreviewDocumentTitleImage");
            break;
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller
                     previewItemAtIndex:(NSInteger)index {
    return self;
}

@end
