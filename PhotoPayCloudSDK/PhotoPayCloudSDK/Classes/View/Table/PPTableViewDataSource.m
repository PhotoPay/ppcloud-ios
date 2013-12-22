//
//  PPTableViewDataSource.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableViewDataSource.h"
#import "PPTableLinearSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@interface PPTableViewDataSource ()

@end

@implementation PPTableViewDataSource

@synthesize sectionCreator;
@synthesize items;

- (id)init {
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
        sectionCreator = [[PPTableLinearSectionCreator alloc] init];
    }
    return self;
}

- (id)initWithSectionCreator:(PPTableSectionCreator*)inSectionCreator {
    self = [super init];
    if (self) {
        sectionCreator = inSectionCreator;
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setSectionCreator:(id)inSectionCreator {
    if (sectionCreator != inSectionCreator) {
        NSArray* allItems = [self items];
        
        [self removeItems:allItems];
        
        sectionCreator = inSectionCreator;
        
        [self insertItems:allItems];
    }
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
            indexPath = [[self sectionCreator] reloadItem:item withItem:item];
            if (indexPath != nil) {
                // if inserted section set contains the section of current index, it will be reloaded anyway
                if (![insertedSectionSet containsIndex:[indexPath section]]) {
                    [reloadedIndexPaths addObject:indexPath];
                }
            }
            [[self items] replaceObjectAtIndex:index withObject:item];
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

- (void)removeItems:(NSArray*)itemsToRemove {
    NSIndexPath *indexPath = nil;
    
    NSMutableIndexSet* deletedSectionSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray* removedIndexPaths = [[NSMutableArray alloc] init];
    
    NSUInteger sectionCount = [[self sections] count];
    
    for (id item in itemsToRemove) {
        
        if ([[self items] containsObject:item]) {
            [[self items] removeObject:item];
            
            indexPath = [[self sectionCreator] removeItem:item];
            
            // check if we deleted a section
            if (sectionCount > [[self sections] count]) {
                sectionCount = [[self sections] count];
                
                // if the section is now empty, add it to deleted sections set
                [deletedSectionSet addIndex:indexPath.section];
                
                // now all removed index paths should be compensated for deleted section
                // all index paths with section index higher than deleted section index should be decremented by 1
                NSMutableArray* newRemovedIndexPaths = [[NSMutableArray alloc] init];
                [removedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *ip = (NSIndexPath*)obj;
                    
                    if ([ip section] >= [indexPath section]) {
                        NSIndexPath *newip = [NSIndexPath indexPathForRow:ip.row inSection:ip.section - 1];
                        [newRemovedIndexPaths addObject:newip];
                    } else {
                        [newRemovedIndexPaths addObject:ip];
                    }
                }];
                removedIndexPaths = newRemovedIndexPaths;
            } else if (indexPath != nil) {
                NSIndexPath __block *nip = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
                [removedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *ip = (NSIndexPath*)obj;
                    // if we already deleted element at index path prior to current index path
                    if ([ip section] == [nip section] && [ip row] <= [nip row]) {
                        nip = [NSIndexPath indexPathForRow:nip.row+1 inSection:nip.section];
                    }
                }];
                
                [removedIndexPaths addObject:nip];
            }
        }
    }
    
    if ([deletedSectionSet count] > 0) {
        [[self delegate] tableViewDataSource:self didDeleteSections:deletedSectionSet];
    }
    if ([removedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didDeleteItemsAtIndexPaths:removedIndexPaths];
    }
}

- (void)reloadItems:(NSArray*)reloadingItems
          withItems:(NSArray*)otherItems {
    
    if ([reloadingItems count] != [otherItems count]) {
        NSLog(@"Items are not of the same length, some will be discarded!");
    }
    
    NSUInteger numIterations = [reloadingItems count];
    if ([otherItems count] < numIterations) {
        numIterations = [otherItems count];
    }
    
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray* itemsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray* itemsToAdd = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numIterations; i++) {
        // try to reload the two matching items
        id first = [reloadingItems objectAtIndex:i];
        id second = [otherItems objectAtIndex:i];
        
        // try reloading the item with section creator
        NSIndexPath *indexPath = [[self sectionCreator] reloadItem:first withItem:second];
        
        if (indexPath != nil) {
            /** If reload was successful, add the index path to reloading list */
            [reloadedIndexPaths addObject:indexPath];
            
            // replace the object
            NSUInteger index = [[self items] indexOfObject:first];
            if (index != NSNotFound) {
                [[self items] replaceObjectAtIndex:index withObject:second];
            }
        } else {
            /** If reload failed, remove the first and insert second object */
            [itemsToAdd addObject:second];
            [itemsToRemove addObject:first];
        }
    }
    
    if ([reloadedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didReloadItemsAtIndexPath:reloadedIndexPaths];
    }

    [self removeItems:itemsToRemove];
    [self insertItems:itemsToAdd];
}

- (id)itemForIndexPath:(NSIndexPath*)indexPath {
    // Obtain section
    PPTableSection *section = [[self sections] objectAtIndex:indexPath.section];
    
    // Return item in given section
    return [[section items] objectAtIndex:indexPath.row];
}

- (NSArray*)sections {
    return [[self sectionCreator] sections];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    PPTableSection *tableSection = (PPTableSection *) ([[self sections] objectAtIndex:section]);
    return [tableSection itemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // this method must be overriden because it cannot instantiate UITableViewCells
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Obtain section
    PPTableSection *tableSection = [[self sections] objectAtIndex:section];
    
    return [tableSection name];
}

@end
