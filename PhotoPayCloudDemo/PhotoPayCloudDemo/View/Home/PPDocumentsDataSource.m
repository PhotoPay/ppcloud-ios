//
//  PPDocumentsDataSource.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsDataSource.h"

#import "PPHomeTableViewCell.h"
#import "PPDocumentDefaultTableViewCell.h"
#import "PPDocumentUploadingTableViewCell.h"

@interface PPDocumentsDataSource ()

+ (PPHomeTableViewCell *)cellForDocumentStateDefault:(PPLocalDocument*)document
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
    
    PPHomeTableViewCell *cell = nil;
    
    switch ([document state]) {
        case PPDocumentStateCreated:
        case PPDocumentStateStored: {
            PPDocumentDefaultTableViewCell *cell1 = (PPDocumentDefaultTableViewCell*)[PPDocumentsDataSource cellForDocumentStateDefault:[document localDocument]
                                                            tableView:tableView];
            cell1.messageLabel.text = _(@"PhotoPayHomeDocumentWaitingForUploadLabel");
            cell = cell1;
            break;
        }
        case PPDocumentStateUploading:
            cell = [PPDocumentsDataSource cellForDocumentStateUploading:[document localDocument]
                                                              tableView:tableView];
            break;
        case PPDocumentStateUploadFailed: {
            PPDocumentDefaultTableViewCell *cell1 = (PPDocumentDefaultTableViewCell*)[PPDocumentsDataSource cellForDocumentStateDefault:[document localDocument]
                                                                                                                              tableView:tableView];
            cell1.messageLabel.text = _(@"PhotoPayHomeDocumentUploadFailedLabel");
            cell = cell1;
            break;
        }
        default: {
            PPDocumentDefaultTableViewCell *cell1 = (PPDocumentDefaultTableViewCell*)[PPDocumentsDataSource cellForDocumentStateDefault:[document localDocument]
                                                                                                                              tableView:tableView];
            cell1.messageLabel.text = _(@"PhotoPayHomeDocumentWaitingForUploadLabel");
            cell = cell1;
            break;
        }
    }
    
    NSLog(@"Section %d, row %d, file %@", [indexPath section], [indexPath row], [document url]);
    
    cell.document = document;
    
    return cell;
}

+ (PPHomeTableViewCell *)cellForDocumentStateDefault:(PPLocalDocument*)document
                                           tableView:(UITableView*)tableView {
    NSString* nibName =  @"PPDocumentDefaultTableViewCell_iPhone";
    PPDocumentDefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (cell == nil) {
        cell = [PPDocumentDefaultTableViewCell allocWithNibName:nibName
                                                            document:document];
    }
    
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
    cell.uploadProgress.progress = [[[documentUploading uploadRequest] progress] floatValue];
    
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
