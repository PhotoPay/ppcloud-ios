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

/** This stores PPDocumentTableSection objects */
@property (nonatomic, strong) NSArray* sections;

@end

@implementation PPTableViewDataSource

@synthesize items;
@synthesize sections;
@synthesize sectionCreator;

- (id)init {
    self = [super init];
    if (self) {
        sectionCreator = [[PPTableLinearSectionCreator alloc] init];
    }
    return self;
}

- (void)setItems:(NSArray *)inItems {
    items = inItems;
    
    sections = [[self sectionCreator] createSectionsForItems:items];
}

- (void)setSectionCreator:(id)inSectionCreator {
    if ([sectionCreator respondsToSelector:@selector(createSectionsForItems:)]) {
        sectionCreator = inSectionCreator;
        sections = [[self sectionCreator] createSectionsForItems:items];
    } else {
        NSLog(@"Invalid section creator, please specify object which inherits PPTableSectionCreator class");
    }
}

- (id)itemForIndexPath:(NSIndexPath*)indexPath {
    // Obtain section
    PPTableSection *section = [[self sections] objectAtIndex:indexPath.section];
    
    // Return item in given section
    return [[section items] objectAtIndex:indexPath.row];
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
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil];
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
