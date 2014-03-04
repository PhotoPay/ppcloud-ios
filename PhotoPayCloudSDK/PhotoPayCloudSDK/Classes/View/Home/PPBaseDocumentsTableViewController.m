//
//  PPDocumentsTableViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 08/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPBaseDocumentsTableViewController.h"
#import "PPPhotoPayCloudService.h"

@interface PPBaseDocumentsTableViewController ()

@end

@implementation PPBaseDocumentsTableViewController

#pragma mark - Initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _documentStates = PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed;
        _pollInterval = @(10.0f);
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _documentStates = PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed;
        _pollInterval = @(10.0f);
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _documentStates = PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed;
        _pollInterval = @(10.0f);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _documentStates = PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed;
        _pollInterval = @(10.0f);
    }
    return self;
}

#pragma mark - Setup / Teardown table data

- (void)setupTableData {
    [super setupTableData];
    
    // this view controller will receive all news about the upload status
    [[PPPhotoPayCloudService sharedService] setUploadDelegate:self];
    
    // this view controller will also receive document fetch events
    [[PPPhotoPayCloudService sharedService] setDocumentsFetchDelegate:self];
    
    // request all documents with appropriate state to be seen inside table view
    [self requestDocuments];
}

- (void)teardownTableData {
    [super teardownTableData];
    
    // this view controller will stop receiving all news about the upload status
    [[PPPhotoPayCloudService sharedService] setUploadDelegate:nil];
    
    [[PPPhotoPayCloudService sharedService] setDocumentsFetchDelegate:nil];
}

#pragma mark - Public methods

- (void)requestDocuments {
    if ([self pollInterval] == nil) {
        [[PPPhotoPayCloudService sharedService] requestDocuments:[self documentStates]];
    } else {
        [[PPPhotoPayCloudService sharedService] requestDocuments:[self documentStates]
                                                    pollInterval:[[self pollInterval] doubleValue]];
    }
}

- (void)openDocument:(PPDocument*)document {
    NSIndexPath* indexPath = [[self dataSource] indexPathForItem:document];
    if (indexPath != nil) {
        [[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:[self tableView] didSelectRowAtIndexPath:indexPath];
    } else {
        PPLogError(@"Cannot find document");
    }
}

- (void)openDocumentAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath != nil) {
        PPDocument* document = [[self dataSource] itemForIndexPath:indexPath];
        if (document == nil) {
            PPLogError(@"No document at index path %@", indexPath);
        } else {
            [[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:[self tableView] didSelectRowAtIndexPath:indexPath];
        }
    } else {
        PPLogError(@"No index path given");
    }
}

#pragma mark - PPDocumentsFetchDelegate

- (void)cloudServiceDidStartFetchingDocuments:(PPPhotoPayCloudService*)service {
    if ([[self delegate] respondsToSelector:@selector(tableViewControllerDidStartFetchingDocuments:)]) {
        [[self delegate] tableViewControllerDidStartFetchingDocuments:self];
    }
}

- (void)cloudService:(PPPhotoPayCloudService*)service didFailedFetchingWithError:(NSError*)error {
    if ([[self delegate] respondsToSelector:@selector(tableViewController:didFailedFetchingWithError:)]) {
        [[self delegate] tableViewController:self didFailedFetchingWithError:error];
    }
}

- (void)cloudServiceDidCancelFetchingDocuments:(PPPhotoPayCloudService*)service {
    if ([[self delegate] respondsToSelector:@selector(tableViewControllerDidCancelFetchingDocuments:)]) {
        [[self delegate] tableViewControllerDidCancelFetchingDocuments:self];
    }
}

- (void)cloudService:(PPPhotoPayCloudService*)service didFinishFetchingWithDocuments:(NSArray*)documents {
    if ([[self delegate] respondsToSelector:@selector(tableViewController:didFinishFetchingWithDocuments:)]) {
        [[self delegate] tableViewController:self didFinishFetchingWithDocuments:documents];
    }
}

#pragma mark - PPTableViewDataSourceDelegate

- (void)tableViewDataSource:(PPTableViewDataSource *)dataSource
         didModifyItemsList:(NSArray *)documents {
    
    if ([[self delegate] respondsToSelector:@selector(tableViewController:didModifyItemsList:)]) {
        [[self delegate] tableViewController:self
                          didModifyItemsList:documents];
    }
    
}

#pragma mark - PPDocumentUploadDelegate

- (void)localDocument:(PPLocalDocument *)localDocument
didUpdateProgressWithBytesWritten:(long long)totalBytesWritten
    totalBytesToWrite:(long long)totalBytesToWrite {

}

- (void)localDocumentDidCancelUpload:(PPLocalDocument *)localDocument {

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self delegate] tableViewController:self willOpenDetailsForDocument:(PPDocument*) [[self dataSource] itemForIndexPath:indexPath]];
}

@end
