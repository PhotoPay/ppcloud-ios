//
//  PPTableSection.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableSection.h"

static const int INITIAL_CAPACITY = 20;

@interface PPTableSection ()

@property (nonatomic, strong) NSMutableArray* mutableItems;

@end

@implementation PPTableSection

@synthesize sectionId;
@synthesize name;
@synthesize mutableItems;

- (id)initWithSectionId:(NSInteger)inSectionId name:(NSString*)inName {
    self = [super init];
    if (self) {
        sectionId = inSectionId;
        name = inName;
        mutableItems = [[NSMutableArray alloc] initWithCapacity:INITIAL_CAPACITY];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PPTableSection *another = [[PPTableSection alloc] initWithSectionId:[self sectionId] name:[self name]];
    [another setMutableItems:[[NSMutableArray alloc] initWithArray:[self items] copyItems:NO]];
    
    return another;
}

- (void)addItem:(id)item {
    [[self mutableItems] addObject:item];
}

- (void)addItem:(id)item atIndex:(NSUInteger)index {
    [[self mutableItems] insertObject:item atIndex:index];
}

- (NSUInteger)removeItem:(id)item {
    NSUInteger index = [[self mutableItems] indexOfObject:item];
    if (index != NSNotFound) {
        [[self mutableItems] removeObjectAtIndex:index];
    }
    return index;
}

- (NSUInteger)reloadItem:(id)item withItem:(id)other {
    NSUInteger index = [[self mutableItems] indexOfObject:item];
    if (index != NSNotFound) {
        [[self mutableItems] replaceObjectAtIndex:index withObject:other];
    }
    return index;
}

/**
 Returns the index of a item in the section if it exists. NSNotFound is returned if it doesn't exist.
 */
- (NSUInteger)indexOfObject:(id)item {
    return [[self mutableItems] indexOfObject:item];
}

- (NSArray *)items {
    return [[self mutableItems] copy];
}

- (NSInteger)itemCount {
    return [[self mutableItems] count];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return true;
    }
    if ([self class] != [other class]) {
        return false;
    }
    return ([self sectionId] == [other sectionId]);
}

@end
