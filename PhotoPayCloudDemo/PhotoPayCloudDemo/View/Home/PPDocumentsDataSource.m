//
//  PPDocumentsDataSource.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsDataSource.h"
#import "PPDocumentTableViewCell.h"

@interface PPDocumentsDataSource ()

@end

@implementation PPDocumentsDataSource

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *documentCellIdentifier = @"PPDocumentTableViewCell";
    PPDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:documentCellIdentifier];
    
    if (cell == nil) {
        cell = [PPDocumentTableViewCell allocWithNibName:@"PPDocumentTableViewCell"];
    }
    
    // Obtain document object for given index path
//    PPDocument *document = [self itemForIndexPath:indexPath];
    
    return cell;
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
