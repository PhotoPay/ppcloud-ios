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
#import "PPSplitTypeDocumentsSectionCreator.h"
#import <UIKit/UIKit.h>

@interface PPDocumentsTableDataSource ()

@end

@implementation PPDocumentsTableDataSource

@synthesize sectionCreator;

- (id)init {
    self = [super init];
    if (self) {
        sectionCreator = [[PPSplitTypeDocumentsSectionCreator alloc] init];
        _documentStates = PPDocumentStateUnknown;
    }
    return self;
}

- (void)removeItemsWithUnallowedStates {
    // find all documents currently in data source which aren't in the state given by documentStates
    NSMutableArray *documentsToRemove = [[NSMutableArray alloc] init];
    
    for (PPDocument* document in [self items]) {
        if (([document state] & [self documentStates]) == 0) {
            [documentsToRemove addObject:document];
        }
    }
    
    if ([documentsToRemove count] > 0) {
        [self removeItems:documentsToRemove];
    }
}

- (void)reloadExistingItems:(NSArray*)reloadItems {
    NSArray* currentItems = [self items];
    NSMutableArray* reloadedIndexPaths = [[NSMutableArray alloc] init];

    [reloadItems enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [currentItems indexOfObject:item];
        if (index != NSNotFound) {
            /** Reloading the element */
            id object = [[self items] objectAtIndex:index];
            if ([object isKindOfClass:[PPDocument class]] &&
                [item isKindOfClass:[PPDocument class]]) {
                
                PPDocument *document = (PPDocument*)object;
                PPDocument *newDocument = (PPDocument*)item;
                
                BOOL changed = [document reloadWithDocument:newDocument];
                
                if (changed) {
                    NSIndexPath* indexPath = [[self sectionCreator] reloadItem:object withItem:object];
                    if (indexPath != nil) {
                        [reloadedIndexPaths addObject:indexPath];
                    }
                }
            }
        } else {
            NSLog(@"Reloading new element??! This should not happen.");
        }
    }];
    
    if ([reloadedIndexPaths count] > 0) {
        [[self delegate] tableViewDataSource:self didReloadItemsAtIndexPath:reloadedIndexPaths];
    }
}

- (void)insertItems:(NSArray*)allItemsToAdd {
    // filter out all items which are not in the allowed states
    NSMutableArray *itemsToAdd = [[NSMutableArray alloc] init];
    for (PPDocument* document in allItemsToAdd) {
        if ([document state] & [self documentStates]) {
            [itemsToAdd addObject:document];
        }
    }
    
    NSMutableSet *currentItemsSet = [[NSMutableSet alloc] initWithArray:[self items]];
    
    NSMutableSet *allItemsSet = [[NSMutableSet alloc] initWithArray:itemsToAdd];
    [allItemsSet intersectSet:currentItemsSet];
    [self reloadExistingItems:[allItemsSet allObjects]];
     
    allItemsSet = [[NSMutableSet alloc] initWithArray:itemsToAdd];
    [allItemsSet minusSet:currentItemsSet];
    [super insertItems:[allItemsSet allObjects]];
}

- (void)reloadItems:(NSArray*)allReloadingItems
          withItems:(NSArray*)allOtherItems {
    
    if ([allReloadingItems count] != [allOtherItems count]) {
        NSLog(@"Items are not of the same length, some will be discarded!");
    }
    
    NSUInteger numIterations = [allReloadingItems count];
    if ([allOtherItems count] < numIterations) {
        numIterations = [allOtherItems count];
    }
    
    NSMutableArray *reloadingItems = [[NSMutableArray alloc] init];
    NSMutableArray *otherItems = [[NSMutableArray alloc] init];
    NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray *itemsToAdd = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numIterations; i++) {
        // try to reload the two matching items
        id first = [allReloadingItems objectAtIndex:i];
        id second = [allOtherItems objectAtIndex:i];
        
        if ([first isKindOfClass:[PPDocument class]] &&
            [second isKindOfClass:[PPDocument class]]) {
            PPDocument *document = (PPDocument*)first;
            PPDocument *newDocument = (PPDocument*)second;
            
            if (([document state] & [self documentStates]) && ([newDocument state] & [self documentStates])) {
                [reloadingItems addObject:document];
                [otherItems addObject:newDocument];
            } else if (([document state] & [self documentStates]) && !([newDocument state] & [self documentStates])) {
                [itemsToRemove addObject:document];
            } else if (!([document state] & [self documentStates]) && ([newDocument state] & [self documentStates])) {
                [itemsToAdd addObject:newDocument];
            }
        } else {
            NSLog(@"Reloading items are not documents. Check your reloading logic.");
        }
    }
    
    [super removeItems:itemsToRemove];
    [super insertItems:itemsToAdd];
    [super reloadItems:reloadingItems withItems:otherItems];
}

@end
