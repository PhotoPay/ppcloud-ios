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
#import "PPDateSortedDocumentsSectionCreator.h"
#import <UIKit/UIKit.h>

@interface PPDocumentsTableDataSource ()

/**
 A list of all items currently in data source
 */
@property (nonatomic, strong, readonly) NSMutableArray* items;

/**
 A list of all items currently in data source, divided into section
 */
@property (nonatomic, strong, readonly) NSArray* sections;

@end

@implementation PPDocumentsTableDataSource

@synthesize items;
@synthesize sectionCreator;

- (id)init {
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
        sectionCreator = [[PPDateSortedDocumentsSectionCreator alloc] init];
    }
    return self;
}

- (void)insertItems:(NSArray*)itemsToAdd {
    NSIndexPath *indexPath = nil;
    
    NSMutableArray* insertedIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];
    
    for (id item in itemsToAdd) {
        NSUInteger index = [[self items] indexOfObject:item];
        if (index == NSNotFound) {
            [[self items] addObject:item];
            indexPath = [[self sectionCreator] insertItem:item];
            
            // new object is inserted, compensate in index paths that were already inserted
            for (int i = 0; i < [insertedIndexPaths count]; i++) {
                NSIndexPath *ip = [insertedIndexPaths objectAtIndex:i];
                if ([ip section] == [indexPath section] && [ip row] >= [indexPath row]) {
                    NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row+1 inSection:ip.section];
                    [insertedIndexPaths replaceObjectAtIndex:i withObject:newip];
                }
            }
            
            // new object is inserted, compensate in index paths that were already inserted
            for (int i = 0; i < [reloadedIndexPaths count]; i++) {
                NSIndexPath *ip = [reloadedIndexPaths objectAtIndex:i];
                if ([ip section] == [indexPath section] && [ip row] >= [indexPath row]) {
                    NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row+1 inSection:ip.section];
                    [reloadedIndexPaths replaceObjectAtIndex:i withObject:newip];
                }
            }
            
            [insertedIndexPaths addObject:indexPath];
        } else {
            id object = [[self items] objectAtIndex:index];
            if ([object isKindOfClass:[PPDocument class]] &&
                [item isKindOfClass:[PPDocument class]]) {
                PPDocument *document = (PPDocument*)object;
                PPDocument *newDocument = (PPDocument*)item;
                
                BOOL changed = [document reloadWithDocument:newDocument];
                
                if (changed) {
                    indexPath = [[self sectionCreator] reloadItem:object withOther:object];
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

- (void)swapLocalDocument:(PPLocalDocument*)localDocument
       withRemoteDocument:(PPRemoteDocument*)remoteDocument {
        
    [remoteDocument setPreviewImage:[localDocument previewImage]];
    [remoteDocument setThumbnailImage:[localDocument thumbnailImage]];
    
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];
    
    NSUInteger index = [[self items] indexOfObject:localDocument];
    
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [[self sectionCreator] reloadItem:localDocument
                                                         withOther:remoteDocument];
        
        [[self items] replaceObjectAtIndex:index withObject:remoteDocument];
        
        if (indexPath != nil) {
            [reloadedIndexPaths addObject:indexPath];
        }
    }
    
    if ([reloadedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didReloadItemsAtIndexPath:reloadedIndexPaths];
    }
}

@end
