//
//  PPDateSortedDocumentsSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/29/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDateSortedDocumentsSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@interface PPDateSortedDocumentsSectionCreator ()

@property (nonatomic, strong) NSMutableArray* sections;

@end


@implementation PPDateSortedDocumentsSectionCreator

@synthesize sections;

- (id)init {
    self = [super init];
    if (self) {
        sections = [[NSMutableArray alloc] init];
        
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:nil];
        
        [sections addObject:section];
    }
    return self;
}

- (NSIndexPath*)insertItem:(id)item {
    PPTableSection *section = [[self sections] objectAtIndex:0];
    
    [section addItem:item atIndex:0];
    
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath*)removeItem:(id)item {
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section removeItem:item];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

- (NSIndexPath*)reloadItem:(id)item withOther:(id)other {
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section reloadItem:item withOther:other];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

@end
