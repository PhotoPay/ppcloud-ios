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
        
        // if we have a local document, everything is fine and dandy
        // however, if we have a remote document, we first need to fetch it from the server
        // and on success, refresh QL controller
        if (([document state] & PPDocumentStateRemote) != 0) {
            [[document remoteDocument] originalDocumentWithSuccess:^(id originalDocument) {
                if ([qlController currentPreviewItem] == self) {
                    [qlController refreshCurrentPreviewItem];
                    NSLog(@"Refreshing!");
                }
            } failure:nil];
        }
    }
    return self;
}

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
    return self;
}

@end
