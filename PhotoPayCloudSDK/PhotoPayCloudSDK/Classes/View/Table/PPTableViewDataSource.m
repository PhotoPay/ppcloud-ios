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

@property (nonatomic, strong) NSMutableArray* sectionsBeforeLastDelegateUpdate;

@end

@implementation PPTableViewDataSource

- (id)init {
    self = [super init];
    if (self) {
        _sectionCreator = [[PPTableLinearSectionCreator alloc] init];
        _sectionsBeforeLastDelegateUpdate = nil;
    }
    return self;
}

- (NSArray*)items {
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    for (id section in [[self sectionCreator] sections]) {
        [allItems addObjectsFromArray:[section items]];
    }
    return allItems;
}

- (id)initWithSectionCreator:(PPTableSectionCreator*)inSectionCreator {
    self = [super init];
    if (self) {
        _sectionCreator = inSectionCreator;
        _sectionsBeforeLastDelegateUpdate = nil;
    }
    return self;
}

- (void)setDelegate:(id<PPTableViewDataSourceDelegate>)delegate {
    _delegate = delegate;
    
    if (delegate == nil) {
        if ([self sectionsBeforeLastDelegateUpdate] == nil) {
            [self setSectionsBeforeLastDelegateUpdate:[[self sectionCreator] sections]];
        }
        return;
    }
    
    NSMutableArray* currentSections = [[self sectionCreator] sections];
    
    NSMutableIndexSet *deletedSectionSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray* newSections = [[self sectionsBeforeLastDelegateUpdate] mutableCopy];
    [[self sectionsBeforeLastDelegateUpdate] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![currentSections containsObject:obj]) {
            [deletedSectionSet addIndex:idx];
            [newSections removeObject:obj];
        }
    }];
    [[self sectionCreator] setSections:newSections];
    if ([deletedSectionSet count] > 0) {
        [[self delegate] tableViewDataSource:self didDeleteSections:deletedSectionSet];
    }
    
    NSMutableIndexSet *insertedSectionSet = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *reloadedSectionSet = [[NSMutableIndexSet alloc] init];
    [currentSections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![[self sectionsBeforeLastDelegateUpdate] containsObject:obj]) {
            [insertedSectionSet addIndex:idx];
        } else {
            [reloadedSectionSet addIndex:idx];
            [newSections insertObject:obj atIndex:idx];
        }
    }];
    
    [[self sectionCreator] setSections:newSections];
    if ([insertedSectionSet count] > 0) {
        [[self delegate] tableViewDataSource:self didInsertSections:insertedSectionSet];
    }
    
    [[self sectionCreator] setSections:currentSections];
    if ([reloadedSectionSet count] > 0) {
        [[self delegate] tableViewDataSource:self didReloadSections:reloadedSectionSet];
    }
    
    [self setSectionsBeforeLastDelegateUpdate:nil];
}

- (void)insertItems:(NSArray*)itemsToAdd {
    PPTableSectionCreator *sectionCreatorCopy = [[self sectionCreator] copy];
    NSUInteger __block currentSectionCount = [sectionCreatorCopy sectionCount];
    
    NSMutableArray* insertedIndexPaths = [[NSMutableArray alloc] init];
    NSMutableIndexSet* indexSetOfItemsWhichInsertedSections = [[NSMutableIndexSet alloc] init];

    // first insert all items into section creator copy
    // and maintain a list of insertedIndexPaths - positions of inserted elements
    // these loops run in O(N_inserted * (N_existing + N_inserted))
    [itemsToAdd enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = [sectionCreatorCopy insertItem:obj];
        BOOL sectionInserted = NO;
        
        if ([sectionCreatorCopy sectionCount] > currentSectionCount) {
            // section is collapsed
            currentSectionCount = [sectionCreatorCopy sectionCount];
            sectionInserted = YES;
        }
        
        [insertedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath *ip = (NSIndexPath *)obj;
            if (sectionInserted && ip.section >= indexPath.section) {
                // if we had previously inserted element at section 2, row 1, and now we inserted new section at 1
                // we move that element to section 3 row 1
                [insertedIndexPaths replaceObjectAtIndex:idx withObject:[NSIndexPath indexPathForRow:ip.row inSection:ip.section + 1]];
            } else if (ip.section == indexPath.section && ip.row >= indexPath.row) {
                // if we had previously inserted element at section 2, row 1, and now we inserted element at section 2, row 0
                // we move that element to section 2 row 2
                [insertedIndexPaths replaceObjectAtIndex:idx withObject:[NSIndexPath indexPathForRow:ip.row + 1 inSection:ip.section]];
            }
        }];
        
        [insertedIndexPaths addObject:indexPath];
        if (sectionInserted) {
            [indexSetOfItemsWhichInsertedSections addIndex:idx];
        }
    }];
    
    NSMutableIndexSet *insertedSectionSet = [[NSMutableIndexSet alloc] init];
    if ([indexSetOfItemsWhichInsertedSections count] > 0) {
        [indexSetOfItemsWhichInsertedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSUInteger sectionIndex = [[insertedIndexPaths objectAtIndex:idx] section];
            [insertedSectionSet addIndex:sectionIndex];
        }];
        
        [insertedSectionSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [[[self sectionCreator] sections] insertObject:[[sectionCreatorCopy sections] objectAtIndex:idx] atIndex:idx];
        }];
        
        [[self delegate] tableViewDataSource:self didInsertSections:insertedSectionSet];
    }
    
    NSMutableArray *otherInsertedIndexPaths = [[NSMutableArray alloc] init];
    
    [insertedIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![insertedSectionSet containsIndex:[obj section]]) {
            [otherInsertedIndexPaths addObject:obj];
        }
    }];
    
    [[self sectionCreator] setSections:[sectionCreatorCopy sections]];
    
    if ([otherInsertedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didInsertItemsAtIndexPaths:otherInsertedIndexPaths];
    }
}

- (void)removeItems:(NSArray*)itemsToRemove {
    PPTableSectionCreator *sectionCreatorCopy = [[self sectionCreator] copy];
    NSUInteger __block currentSectionCount = [sectionCreatorCopy sectionCount];
    
    NSMutableArray* removedIndexSets = [[NSMutableArray alloc] init];
    NSMutableIndexSet *removedSectionSet = [[NSMutableIndexSet alloc] init];
    
    // first remove all items from section creator copy
    // and maintain a list of removedIndexPaths - positions of removed elements
    // these loops run in O(N_removed * (N_existing + N_removed))
    [itemsToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = [sectionCreatorCopy removeItem:obj];
        BOOL sectionRemoved = NO;
        
        if ([sectionCreatorCopy sectionCount] < currentSectionCount) {
            // section is collapsed
            currentSectionCount = [sectionCreatorCopy sectionCount];
            sectionRemoved = YES;
        }
        
        NSUInteger __block sectionOffset = 0;
        NSUInteger __block rowOffset = 0;
        
        [removedSectionSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if (idx <= [indexPath section] + sectionOffset) {
                sectionOffset++;
            }
        }];
        
        if (sectionRemoved) {
            [removedSectionSet addIndex:[indexPath section] + sectionOffset];
        }
        
        while ([removedIndexSets count] < [indexPath section] + sectionOffset + 1) {
            [removedIndexSets addObject:[[NSMutableIndexSet alloc] init]];
        }
        
        NSMutableIndexSet *indexSet = [removedIndexSets objectAtIndex:[indexPath section] + sectionOffset];
        
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if (idx <= indexPath.row + rowOffset) {
                rowOffset++;
            } else {
                *stop = YES;
            }
        }];
        
        [indexSet addIndex:indexPath.row + rowOffset];
    }];
    
    if ([removedSectionSet count] > 0) {
        NSMutableArray *indexes = [[NSMutableArray alloc] init];
        
        [removedSectionSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexes insertObject:@(idx) atIndex:0];
        }];
        
        [indexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [[[self sectionCreator] sections] removeObjectAtIndex:[obj unsignedIntegerValue]];
        }];
        
        [[self delegate] tableViewDataSource:self didDeleteSections:removedSectionSet];
    }
    
    NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
    NSUInteger sectionOffset = 0;
    for (int i = 0; i < [removedIndexSets count]; i++) {
        if (![removedSectionSet containsIndex:i]) {
            [[removedIndexSets objectAtIndex:i] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [removedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:i - sectionOffset]];
            }];
        } else {
            sectionOffset++;
        }
    }
    
    [[self sectionCreator] setSections:[sectionCreatorCopy sections]];
    
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
    if (indexPath.section < [[self sections] count]) {
        // Obtain section
        PPTableSection *section = [[self sections] objectAtIndex:indexPath.section];
        
        if ([indexPath row] < [section itemCount]) {
            // Return item in given section
            return [[section items] objectAtIndex:indexPath.row];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
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
