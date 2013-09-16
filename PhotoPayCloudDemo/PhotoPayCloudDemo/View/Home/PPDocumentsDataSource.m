//
//  PPDocumentsDataSource.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsDataSource.h"
#import "PPDocumentTableViewCell.h"

#import "PPHomeTableViewCell.h"
#import "PPDocumentCreatedTableViewCell.h"
#import "PPDocumentUploadingTableViewCell.h"

@interface PPDocumentsDataSource ()

+ (PPHomeTableViewCell *)cellForDocumentStateCreated:(PPLocalDocument*)documentCreated
                                           tableView:(UITableView*)tableView;

+ (PPHomeTableViewCell *)cellForDocumentStateStored:(PPLocalDocument*)documentStored
                                          tableView:(UITableView*)tableView;

+ (PPHomeTableViewCell *)cellForDocumentStateUploading:(PPLocalDocument*)documentUploading
                                             tableView:(UITableView*)tableView;

@end

@implementation PPDocumentsDataSource

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Obtain document object for given index path
    PPDocument *document = [self itemForIndexPath:indexPath];
    
    NSLog(@"Reloading cell %d, Document state is %@", [indexPath row], [PPDocument objectForDocumentState:[document state]]);
    
    PPHomeTableViewCell *cell = nil;
    
    switch ([document state]) {
        case PPDocumentStateCreated:
            cell = [PPDocumentsDataSource cellForDocumentStateCreated:[document localDocument]
                                                            tableView:tableView];
            break;
        case PPDocumentStateStored:
            NSLog(@"Stored cell!");
            cell = [PPDocumentsDataSource cellForDocumentStateStored:[document localDocument]
                                                           tableView:tableView];
            break;
        case PPDocumentStateUploading:
            NSLog(@"Uploading cell!");
            cell = [PPDocumentsDataSource cellForDocumentStateUploading:[document localDocument]
                                                              tableView:tableView];
            break;
        default:
            cell = [PPDocumentsDataSource cellForDocumentStateStored:[document localDocument]
                                                            tableView:tableView];
            break;
    }
    
    return cell;
}

+ (PPHomeTableViewCell *)cellForDocumentStateCreated:(PPLocalDocument*)documentCreated
                                           tableView:(UITableView*)tableView {
    NSString* nibName =  @"PPDocumentCreatedTableViewCell_iPhone";
    PPDocumentCreatedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (cell == nil) {
        cell = [PPDocumentCreatedTableViewCell allocWithNibName:nibName
                                                       document:documentCreated];
    }
    
    cell.messageLabel.text = _(@"PhotoPayHomeDocumentCreatedLabel");
    
    return cell;
}

+ (PPHomeTableViewCell *)cellForDocumentStateStored:(PPLocalDocument*)documentStored
                                          tableView:(UITableView*)tableView {
    NSString* nibName =  @"PPDocumentCreatedTableViewCell_iPhone";
    PPDocumentCreatedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (cell == nil) {
        cell = [PPDocumentCreatedTableViewCell allocWithNibName:nibName
                                                       document:documentStored];
    }
    
    cell.messageLabel.text = _(@"PhotoPayHomeDocumentStoredLabel");
    
    return cell;
}

+ (PPHomeTableViewCell *)cellForDocumentStateUploading:(PPLocalDocument*)documentUploading
                                             tableView:(UITableView*)tableView {
    NSString* nibName =  @"PPDocumentUploadingTableViewCell_iPhone";
    PPDocumentUploadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (cell == nil) {
        cell = [PPDocumentUploadingTableViewCell allocWithNibName:nibName
                                                         document:documentUploading];
    }
    
    cell.messageLabel.text = _(@"PhotoPayHomeDocumentUploadingLabel");
    cell.uploadProgress.progress = [[[[[cell document] localDocument] uploadRequest] progress] floatValue];
    NSLog(@"Document %@, progress %f", [[[cell document] localDocument] url], cell.uploadProgress.progress);
    
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
