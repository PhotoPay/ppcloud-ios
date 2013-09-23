//
//  PPTableLinearSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableLinearSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@interface PPTableLinearSectionCreator ()

@property (nonatomic, strong) NSMutableArray* sections;

@end

@implementation PPTableLinearSectionCreator

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
    int sectionIndex = [[self sections] count] - 1;
    PPTableSection *section = [[self sections] objectAtIndex:sectionIndex];
    
    [section addItem:item];
    
    int rowIndex = [section itemCount] - 1;
    return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
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

- (NSIndexPath*)reloadItem:(id)item {
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section reloadItem:item];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

@end
