//
//  PPDocumentsTableViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 08/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPDocumentsTableViewController.h"
#import "PPDocumentsDataSource.h"
#import "PPDocumentTableViewCell.h"
#import "PPDocumentTableViewCell+Uploading.h"

@interface PPDocumentsTableViewController ()

@end

@implementation PPDocumentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.dataSource = [[PPDocumentsDataSource alloc] init];
    
    // Specify section creator object which splits the uploading documents into two sections
    // One for uploading documents, one for those which are processing or done
    
    PPSplitTypeDocumentsSectionCreator* sectionCreator = [[PPSplitTypeDocumentsSectionCreator alloc] init];
    [sectionCreator setUploadingSectionTitle:_(@"PhotoPayHomeUploadingSectionTitle")];
    [sectionCreator setProcessedSectionTitle:_(@"PhotoPayHomeProcessedSectionTitle")];
    self.dataSource.sectionCreator = sectionCreator;
    
    [[PPPhotoPayCloudService sharedService] setDataSource:(PPDocumentsDataSource*)[self dataSource]];
    
    // Add padding to content for take photo button
    UIEdgeInsets insets = [self tableView].contentInset;
    insets.bottom = 100;
    [self tableView].contentInset = insets;
}

#pragma mark - PPDocumentUploadDelegate

- (void)localDocument:(PPLocalDocument *)localDocument
didUpdateProgressWithBytesWritten:(long long)totalBytesWritten
    totalBytesToWrite:(long long)totalBytesToWrite {
    
    // instead of requesting the whole table to update, we just find the potential cell among visible cells
    for (PPDocumentTableViewCell* cell in self.tableView.visibleCells) {
        if (cell.document.state == PPDocumentStateUploading) {
            [cell refreshProgress];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PPDocumentTableViewCell defaultHeight];
}

@end
