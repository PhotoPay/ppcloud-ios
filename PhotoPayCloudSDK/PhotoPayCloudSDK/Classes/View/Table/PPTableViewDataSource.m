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

@interface PPTableViewDataSource ()

@end

@implementation PPTableViewDataSource

@synthesize sectionCreator;
@synthesize items;

- (id)init {
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
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
    
    NSMutableArray* insertedIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];
    
    for (id item in itemsToAdd) {
        NSUInteger index = [[self items] indexOfObject:item];
        if (index == NSNotFound) {
            [[self items] addObject:item];
            indexPath = [[self sectionCreator] insertItem:item];
            [insertedIndexPaths addObject:indexPath];
        } else {
            indexPath = [[self sectionCreator] reloadItem:item withOther:item];
            [[self items] replaceObjectAtIndex:index withObject:item];
            if (indexPath != nil) {
                [reloadedIndexPaths addObject:indexPath];
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

- (void)removeItems:(NSArray*)itemsToRemove {
    NSIndexPath *indexPath = nil;
    
    NSMutableArray* removedIndexPaths = [[NSMutableArray alloc] init];
    for (id item in itemsToRemove) {
        if ([[self items] containsObject:item]) {
            indexPath = [[self sectionCreator] removeItem:item];
            if (indexPath != nil) {
                [removedIndexPaths addObject:indexPath];
            }
        }
    }
    
    if ([removedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didDeleteItemsAtIndexPaths:removedIndexPaths];
    }
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
