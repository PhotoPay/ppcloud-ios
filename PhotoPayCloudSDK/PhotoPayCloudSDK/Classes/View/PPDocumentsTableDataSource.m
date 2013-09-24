//
//  PPDocumentsTableDataSource.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/16/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsTableDataSource.h"
#import "PPDocument.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import "PPLocalDocumentUploadQueue.h"
#import "PPTableSectionCreator.h"

@interface PPDocumentsTableDataSource ()

@end

@implementation PPDocumentsTableDataSource

- (void)insertItems:(NSArray*)itemsToAdd {
    NSIndexPath *indexPath = nil;
    
    NSMutableArray* insertedIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];
    
    for (id item in itemsToAdd) {
        NSUInteger index = [[self items] indexOfObject:item];
        if (index == NSNotFound) {
            [[self items] addObject:item];
            indexPath = [[self sectionCreator] insertItem:item];
            [insertedIndexPaths addObject:indexPath];
        } else {
            indexPath = [[self sectionCreator] reloadItem:item];
            
            id object = [[self items] objectAtIndex:index];
            if ([object isKindOfClass:[PPDocument class]] &&
                [item isKindOfClass:[PPDocument class]]) {
                PPDocument *document = (PPDocument*)object;
                PPDocument *newDocument = (PPDocument*)item;
                
                BOOL changed = [document reloadWithDocument:newDocument];
                
                if (changed) {
                    [[self items] replaceObjectAtIndex:index withObject:object];
                    if (indexPath != nil) {
                        [reloadedIndexPaths addObject:indexPath];
                    }
                }
            }
        }
    }
    
    if ([insertedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths];
    }
    if ([reloadedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didReloadItemsAtIndexPath:reloadedIndexPaths];
    }
}

@end
