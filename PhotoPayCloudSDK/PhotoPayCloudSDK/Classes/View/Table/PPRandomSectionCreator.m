//
//  PPRandomSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 04/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPRandomSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@interface PPRandomSectionCreator ()

@property (nonatomic) NSUInteger maxSectionCount;
@end

@implementation PPRandomSectionCreator

- (id)init {
    self = [super init];
    if (self) {
        _maxSectionCount = 5;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PPRandomSectionCreator *another = [super copyWithZone:zone];
    another->_maxSectionCount = self->_maxSectionCount;
    return another;
}

- (NSIndexPath*)insertItem:(id)item {
    static NSUInteger insertedIndex = 0;
    
    NSUInteger sectionIndex = arc4random_uniform(MIN([self sectionCount] + 1, [self maxSectionCount]));
    
    if (sectionIndex >= [self sectionCount]) {
        insertedIndex++;
        
        PPTableSection *insertedSection = [[PPTableSection alloc] initWithSectionId:insertedIndex
                                                                               name:[NSString stringWithFormat:@"Section %u", insertedIndex]];
        
        // insert in random place
        sectionIndex = arc4random_uniform([self sectionCount] + 1);
        [[self sections] insertObject:insertedSection atIndex:sectionIndex];
    }
    
    PPTableSection* section = [[self sections] objectAtIndex:sectionIndex];
    
    NSUInteger elementIndex = arc4random_uniform([section itemCount] + 1);
    
    [section addItem:item atIndex:elementIndex];
    
    return [NSIndexPath indexPathForRow:elementIndex inSection:sectionIndex];
}

- (NSIndexPath*)removeItem:(id)item {
    NSIndexPath* indexPath = [super removeItem:item];
    if (indexPath != nil) {
        PPTableSection* section = [[self sections] objectAtIndex:[indexPath section]];
        if ([section itemCount] == 0) {
            if (arc4random_uniform(2) == 1) {
                [[self sections] removeObject:section];
            }
        }
    }
    return indexPath;
}

@end
