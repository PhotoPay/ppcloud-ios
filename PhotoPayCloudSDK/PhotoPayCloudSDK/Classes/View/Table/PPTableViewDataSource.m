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

- (NSArray*)sortedItems:(NSArray*)unsortedItems {
    
    // sort items according to position in sections
    NSArray* sortedItems = [unsortedItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath* ip1 = [[self sectionCreator] indexPathForObject:obj1];
        NSIndexPath* ip2 = [[self sectionCreator] indexPathForObject:obj2];
        return [ip1 compare:ip2];
    }];
    
    return sortedItems;
}

- (void)removeItems:(NSArray*)itemsToRemove {
    NSMutableIndexSet* deletedSectionSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray* removedIndexPaths = [[NSMutableArray alloc] init];
    
    NSArray* sortedItemsToRemove = [self sortedItems:itemsToRemove];
    NSMutableArray* sortedIndexPaths = [[NSMutableArray alloc] init];
    [sortedItemsToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = [[self sectionCreator] indexPathForObject:obj];
        if (indexPath != nil) {
            [sortedIndexPaths addObject:indexPath];
        } else {
            [sortedIndexPaths addObject:[NSNull null]];
        }
    }];
    
    PPTableSectionCreator *sectionCreatorCopy = [[self sectionCreator] copy];
    NSUInteger currentSectionCount = [sectionCreatorCopy sectionCount];
    
    // for each section, find if it is completely removed. Theese loops go in O(number_of_items_to_remove)
    int itemIndex = 0;
    for (int sectionIndex = 0; sectionIndex < [sectionCreatorCopy sectionCount]; sectionIndex++) {
        for (; itemIndex < [sortedItemsToRemove count];) {
            id item = [sortedItemsToRemove objectAtIndex:itemIndex];
            id indexPath = [sortedIndexPaths objectAtIndex:itemIndex];
            
            if ([indexPath isEqual:[NSNull null]]) {
                itemIndex++;
                continue;
            }
            
            // skip if section of the current item is larger than sectionIndex
            if ([indexPath section] > sectionIndex) {
                break;
            } else {
                itemIndex++; // move to the next item
            }
            
            // remove the item to see if it collapses the section
            [sectionCreatorCopy removeItem:item];
            if ([sectionCreatorCopy sectionCount] < currentSectionCount) {
                // section is collapsed
                currentSectionCount = [sectionCreatorCopy sectionCount];
                [deletedSectionSet addIndex:sectionIndex];
            }
        }
    }
    
    // now, for each item which is in one of the deleted sections, remove it from the data source
    for (int itemIndex = 0; itemIndex < [sortedItemsToRemove count]; itemIndex++) {
        id item = [sortedItemsToRemove objectAtIndex:itemIndex];
        
        id indexPath = [sortedIndexPaths objectAtIndex:itemIndex];
        if ([indexPath isEqual:[NSNull null]]) {
            itemIndex++;
            continue;
        }
        
        if ([deletedSectionSet containsIndex:[indexPath section]]) {
            [[self sectionCreator] removeItem:item];
        }
    }
    
    // notify delegate about removed sections
    if ([deletedSectionSet count] > 0) {
        [[self delegate] tableViewDataSource:self didDeleteSections:deletedSectionSet];
    }
    
    // delete the rest of items, from the last to the first
    for (int itemIndex = [sortedItemsToRemove count] - 1; itemIndex >= 0; itemIndex--) {
        id item = [sortedItemsToRemove objectAtIndex:itemIndex];
        
        id indexPath = [sortedIndexPaths objectAtIndex:itemIndex];
        if ([indexPath isEqual:[NSNull null]]) {
            itemIndex--;
            continue;
        }
        
        if (![deletedSectionSet containsIndex:[indexPath section]]) {
            NSIndexPath* indexPath = [[self sectionCreator] removeItem:item];
            [removedIndexPaths addObject:indexPath];
        }
    }
    
    // remove items from data source
    for (id item in itemsToRemove) {
        [[self items] removeObject:item];
    }
    
    // inform delegate
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
