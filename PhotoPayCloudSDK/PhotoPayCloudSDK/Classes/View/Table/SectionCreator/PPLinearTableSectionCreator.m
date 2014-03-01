//
//  PPTableLinearSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLinearTableSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@implementation PPLinearTableSectionCreator

- (id)init {
    self = [super init];
    if (self) {
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:nil];
        [[self sections] addObject:section];
    }
    return self;
}

- (NSIndexPath*)insertItem:(id)item {
    // always place in section 0
    PPTableSection *section = [[self sections] objectAtIndex:0];
    
    // always place at the last place
    [section addItem:item];
    
    return [NSIndexPath indexPathForRow:[section itemCount] - 1 inSection:0];
}

@end
