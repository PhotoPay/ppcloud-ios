//
//  PPDocumentsDataSource.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsDataSource.h"
#import "PPDocumentTableSection.h"
#import "PPDocumentTableViewCell.h"

@interface PPDocumentsDataSource ()

- (void)buildTableSections;

/** This stores PPDocumentTableSection objects */
@property (nonatomic, strong) NSArray* sections;

@end

@implementation PPDocumentsDataSource

@synthesize documents;
@synthesize sections;

- (void)setDocuments:(NSArray*)inDocuments {
    documents = inDocuments;
    
    [self buildTableSections];
}

- (void)buildTableSections {
    
    // simple table section building strategy, just push all documents into one section
    PPDocumentTableSection *section1 = [[PPDocumentTableSection alloc] initWithSectionId:0 name:nil];
    
    for (PPDocument *document in [self documents]) {
        [section1 addDocument:document];
    }
    
    sections = [[NSArray alloc] initWithObjects:section1, nil];
}

- (PPDocument*)documentForIndexPath:(NSIndexPath*)indexPath {
    
    // Obtain section
    PPDocumentTableSection *section = [[self sections] objectAtIndex:indexPath.section];
    
    // Obtain document in given section
    PPDocument *document = [[section items] objectAtIndex:indexPath.row];
    
    return document;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    PPDocumentTableSection *tableSection = (PPDocumentTableSection *) ([[self sections] objectAtIndex:section]);
    return [[tableSection items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *documentCellIdentifier = @"PPDocumentTableViewCell";
    PPDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:documentCellIdentifier];
    
    if (cell == nil) {
        cell = [PPDocumentTableViewCell allocWithNibName:@"PPDocumentTableViewCell"];
    }
    
    // Obtain document object for given index path
//    PPDocument *document = [self documentForIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Obtain section
    PPDocumentTableSection *tableSection = [[self sections] objectAtIndex:section];
    
    return [tableSection name];
}

// Editing (TODO:)
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Moving/reordering
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
