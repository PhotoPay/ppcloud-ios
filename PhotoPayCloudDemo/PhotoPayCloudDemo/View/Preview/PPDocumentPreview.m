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

#pragma mark - QLPreviewItem

- (NSURL *)previewItemURL {
    return [self.document cachedDocumentUrl];
}

- (NSString *)previewItemTitle {
    return _(@"PhotoPayPreviewDocumentTitle");
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller
                     previewItemAtIndex:(NSInteger)index {
    // if we have a local document, everything is fine and dandy, we have a document
    
    // however, if we have a remote document, we first need to fetch it from the server
    if (([[self document] state] & PPDocumentStateRemote) != 0) {
        
    }
}

@end
