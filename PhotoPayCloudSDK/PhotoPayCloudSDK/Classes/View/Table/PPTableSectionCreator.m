//
//  PPTableSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@implementation PPTableSectionCreator

- (id)init {
    self = [super init];
    if (self) {
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PPTableSectionCreator *another = [[[self class] allocWithZone:zone] init];
    [another setSections:[[NSMutableArray alloc] initWithArray:[self sections] copyItems:YES]];
    return another;
}

- (NSString*)description {
    NSString *desc = [NSString stringWithFormat:@"Section creator with %u sections", [self sectionCount]];
    for (int i = 0; i < [self sectionCount]; i++) {
        id section = [[self sections] objectAtIndex:i];
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@", section %d, items: %d", i, [section itemCount]]];
    }
    return desc;
}

- (PPTableSection*)findSectionWithId:(NSInteger)sectionId {
    for (PPTableSection* section in _sections) {
        if ([section sectionId] == sectionId) {
            return section;
        }
    }
    return nil;
}

- (NSUInteger)sectionCount {
    return [[self sections] count];
}

- (NSIndexPath*)indexPathForObject:(id)item {
    for (int i = 0; i < [self sectionCount]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section indexOfObject:item];
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

- (NSUInteger)indexForSection:(id)item {
    for (int i = 0; i < [self sectionCount]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        if ([section sectionId] == [item sectionId]) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (NSIndexPath*)insertItem:(id)item {
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (NSIndexPath*)removeItem:(id)item {
    for (int i = 0; i < [self sectionCount]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section removeItem:item];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

- (NSIndexPath*)reloadItem:(id)item withItem:(id)other {
    for (int i = 0; i < [self sectionCount]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section reloadItem:item withItem:other];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

@end
