//
//  PPDateSortedDocumentsSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/29/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDateSortedDocumentsSectionCreator.h"
#import "PPTableSection.h"
#import "PPDocument.h"
#import <UIKit/UIKit.h>

@implementation PPDateSortedDocumentsSectionCreator

- (id)init {
    self = [super init];
    if (self) {
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:nil];
        [[self sections] addObject:section];
    }
    return self;
}

- (NSIndexPath*)insertItem:(id)item {
    // we always insert into first section
    
    PPDocument *insertingDocument = nil;
    if ([item isKindOfClass:[PPDocument class]]) {
        insertingDocument = (PPDocument *)item;
    } else {
        return nil;
    }
    
    PPTableSection *section = [[self sections] objectAtIndex:0];
    
    int i = 0;
    for (; i < [section itemCount]; i++) {
        
        // we find the item with date larger than current
        // and then break the loop
        NSObject *obj = [[section items] objectAtIndex:i];
        if ([obj isKindOfClass:[PPDocument class]]) {
            PPDocument *document = (PPDocument *)obj;
            
            if ([[document creationDate] compare:[insertingDocument creationDate]] == NSOrderedAscending) {
                break;
            }
        }
    }
    
    [section addItem:item atIndex:i];
    
    return [NSIndexPath indexPathForRow:i inSection:0];
}

@end
