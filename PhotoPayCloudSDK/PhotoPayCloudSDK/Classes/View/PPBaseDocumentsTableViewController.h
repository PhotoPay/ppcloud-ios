//
//  PPDocumentsTableViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jura on 08/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "PPUploadRequestOperation.h"
#import "PPDocumentsFetchDelegate.h"
#import "PPDocument.h"

@protocol PPDocumentsTableViewControllerDelegate;

/**
 Table view controller is responsible for maintaining Documents table view, with all their
 state tracking, polling, etc.
 */
@interface PPBaseDocumentsTableViewController : PPTableViewController <PPDocumentUploadDelegate, PPDocumentsFetchDelegate>

/**
 Document states which are shown in the table
 */
@property (nonatomic, assign) PPDocumentState documentStates;

/** If nil, poll is not used */
@property (nonatomic, strong) NSNumber* pollInterval;

/**
 Table view controller notifies this object for important events 
 */
@property (nonatomic, weak) id<PPDocumentsTableViewControllerDelegate> delegate;

/**
 Requests the documents with current document states.
 
 After changing document states, requestDocuments needs to be called to avoid polling
 for previously used states
 */
- (void)requestDocuments;

/**
 Open details for a specific document
 */
- (void)openDocument:(PPDocument*)document;

/**
 Open details for document located at a given index path
 */
- (void)openDocumentAtIndexPath:(NSIndexPath*)indexPath;

@end

/**
 Protocol which the object which wants to be notified on DocumentsTableViewController important
 events
 */
@protocol PPDocumentsTableViewControllerDelegate <NSObject>

@required

/**
 Called when table view controller wants to open details for a specific document
 */
- (void)tableViewController:(id)controller willOpenDetailsForDocument:(PPDocument*)document;

@optional

/**
 Called when table view controller starts fetching remote documents
 */
- (void)tableViewControllerDidStartFetchingDocuments:(id)controller;

/**
 Called when table view controller finished fetching remote documents with error
 */
- (void)tableViewController:(id)controller
 didFailedFetchingWithError:(NSError*)error;

/**
 Called when table view controller was canceled while fetching remote documents
 */
- (void)tableViewControllerDidCancelFetchingDocuments:(id)controller;

/**
 Called when table view controller finished fetching remote documents
 
 Also, a list of all documents in table view data source is passed as a parameter.
 */
- (void)tableViewController:(id)controller
didFinishFetchingWithDocuments:(NSArray*)documents;

/**
 Called when table view controller's data source document list was modified.
 */
- (void)tableViewController:(id)controller
         didModifyItemsList:(NSArray*)items;

@end
