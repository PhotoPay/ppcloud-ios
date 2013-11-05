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
#import "PPDefaultDocumentsSectionCreator.h"
#import <UIKit/UIKit.h>

@interface PPDocumentsTableDataSource ()

/**
 A list of all items currently in data source
 */
@property (nonatomic, strong, readonly) NSMutableArray* items;

@end

@implementation PPDocumentsTableDataSource

@synthesize items;
@synthesize sectionCreator;

- (id)init {
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
        sectionCreator = [[PPDefaultDocumentsSectionCreator alloc] init];
    }
    return self;
}

- (void)insertItems:(NSArray*)itemsToAdd {
    NSIndexPath *indexPath = nil;
    
    NSMutableIndexSet* insertedSectionSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray* insertedIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];
    
    int sectionCount = [[self sections] count];
    
    for (id item in itemsToAdd) {
        NSUInteger index = [[self items] indexOfObject:item];
        
        if (index == NSNotFound) {
            /** Inserting the element */
            [[self items] addObject:item];
            
            // insert using the current section creator, get index path of the inserted element
            indexPath = [[self sectionCreator] insertItem:item];
            
            // if section creator added a new section
            if ([[self sections] count] > sectionCount) {
                
                // set the new section count
                sectionCount = [[self sections] count];

                /** update the indexes of all inserted sections which appear after the currently added section */
                NSMutableIndexSet* newInsertedSectionSet = [[NSMutableIndexSet alloc] init];
                [insertedSectionSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    if (idx >= indexPath.section) {
                        [newInsertedSectionSet addIndex:idx+1];
                    } else {
                        [newInsertedSectionSet addIndex:idx];
                    }
                    
                }];
                [newInsertedSectionSet addIndex:indexPath.section];
                insertedSectionSet = newInsertedSectionSet;
                
                /** update the section index of all inserted indexes which are in section equal to or greater than the new section */
                NSMutableArray* newInsertedIndexPaths = [[NSMutableArray alloc] init];
                [insertedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *ip = (NSIndexPath*)obj;
                    
                    if ([ip section] >= [indexPath section]) {
                        NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row inSection:ip.section+1];
                        [newInsertedIndexPaths addObject:newip];
                    } else {
                        [newInsertedIndexPaths addObject:ip];
                    }
                }];
                insertedIndexPaths = newInsertedIndexPaths;
                
                /** update the section index of all reloaded indexes which are in section equal to or greater than the new section */
                NSMutableArray* newReloadedIndexPaths = [[NSMutableArray alloc] init];
                
                [reloadedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *ip = (NSIndexPath*)obj;
                    
                    if ([ip section] >= [indexPath section]) {
                        NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row inSection:ip.section+1];
                        [newReloadedIndexPaths addObject:newip];
                    } else {
                        [newReloadedIndexPaths addObject:ip];
                    }
                }];
                reloadedIndexPaths = newReloadedIndexPaths;
            } else {
                
                // if inserted section set contains the section of current index, it will be reloaded anyway
                if ([insertedSectionSet containsIndex:[indexPath section]]) {
                    continue;
                }
                
                /** Update the row index of all objects inserted in this section after the current item */
                NSMutableArray* newInsertedIndexPaths = [[NSMutableArray alloc] init];
                [insertedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *ip = (NSIndexPath*)obj;
                    
                    if ([ip section] == [indexPath section] && [ip row] >= [indexPath row]) {
                        NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row+1 inSection:ip.section];
                        [newInsertedIndexPaths addObject:newip];
                    } else {
                        [newInsertedIndexPaths addObject:ip];
                    }
                }];
                [newInsertedIndexPaths addObject:indexPath];
                insertedIndexPaths = newInsertedIndexPaths;
                
                /** Update the row index of all objects reloaded in this section after the current item */
                NSMutableArray* newReloadedIndexPaths = [[NSMutableArray alloc] init];
                
                [reloadedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *ip = (NSIndexPath*)obj;
                    
                    if ([ip section] == [indexPath section] && [ip row] >= [indexPath row]) {
                        NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row+1 inSection:ip.section];
                        [newReloadedIndexPaths addObject:newip];
                    } else {
                        [newReloadedIndexPaths addObject:ip];
                    }
                }];
                reloadedIndexPaths = newReloadedIndexPaths;
            }
        } else {
            /** Reloading the element */
            id object = [[self items] objectAtIndex:index];
            if ([object isKindOfClass:[PPDocument class]] &&
                [item isKindOfClass:[PPDocument class]]) {
                PPDocument *document = (PPDocument*)object;
                PPDocument *newDocument = (PPDocument*)item;
                
                BOOL changed = [document reloadWithDocument:newDocument];
                
                if (changed) {
                    indexPath = [[self sectionCreator] reloadItem:object withItem:object];
                    [[self items] replaceObjectAtIndex:index withObject:object];
                    if (indexPath != nil) {
                        
                        // if inserted section set contains the section of current index, it will be reloaded anyway
                        if (![insertedSectionSet containsIndex:[indexPath section]]) {
                            [reloadedIndexPaths addObject:indexPath];
                        }
                    }
                }
            }
        }
    }
    
    if ([insertedSectionSet count] > 0) {
        [[self delegate] tableViewDataSource:self didInsertSections:insertedSectionSet];
    }
    if ([insertedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths];
    }
    if ([reloadedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didReloadItemsAtIndexPath:reloadedIndexPaths];
    }
}

@end
