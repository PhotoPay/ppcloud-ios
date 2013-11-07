//
//  PPHomeViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeViewController.h"
#import "PPDocumentsDataSource.h"
#import "UIViewController+Modal.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PPAlertView.h"
#import "PPDocumentTableViewCell+Uploading.h"
#import "PPDocumentDetailsViewController.h"
#import <DDLog.h>

@interface PPHomeViewController () <UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PPDocumentUploadDelegate, PPTableViewDataSourceDelegate>

@property (nonatomic, strong) PPDocumentsDataSource* documentsDataSource;

- (void)uploadDocument:(PPLocalDocument*)document;

- (void)setupTableData;

- (void)teardownTableData;

- (void)setupNotifications;

- (void)didEnterBackground:(NSNotification*)notification;

- (void)willEnterForeground:(NSNotification*)notification;

@end

@implementation PPHomeViewController

@synthesize documentsDataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:_(@"PhotoPayHomeTitle")];
    
    self.documentsDataSource = [[PPDocumentsDataSource alloc] init];
    [self.documentsDataSource setDelegate:self];
    
    // Specify section creator object which splits the uploading documents into two sections
    // One for uploading documents, one for those which are processing or done
    PPSplitTypeDocumentsSectionCreator* sectionCreator = [[PPSplitTypeDocumentsSectionCreator alloc] init];
    [sectionCreator setUploadingSectionTitle:_(@"PhotoPayHomeUploadingSectionTitle")];
    [sectionCreator setProcessedSectionTitle:_(@"PhotoPayHomeProcessedSectionTitle")];
    self.documentsDataSource.sectionCreator = sectionCreator;
    
//    PPDateSortedDocumentsSectionCreator* sectionCreator = [[PPDateSortedDocumentsSectionCreator alloc] init];
//    self.documentsDataSource.sectionCreator = sectionCreator;
    
    [[PPPhotoPayCloudService sharedService] setDataSource:documentsDataSource];
    [[self billsTable] setDataSource:[self documentsDataSource]];
    [[self billsTable] setDelegate:self];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [[self cameraButton] setEnabled:NO];
    }
}

- (void)viewDidUnload {
    self.documentsDataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupTableData];
    
    // To clear any selection in the table view before it’s displayed
    [[self billsTable] deselectRowAtIndexPath:[[self billsTable] indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // flash the scroll view’s scroll indicators
    [[self billsTable] flashScrollIndicators];
    
    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self teardownTableData];
}

- (void)setupTableData {
    // this view controller will receive all news about the upload status
    [[PPPhotoPayCloudService sharedService] setUploadDelegate:self];
    
    // request all local documents and remote unconfirmed to be seen inside table view
    [[PPPhotoPayCloudService sharedService] requestDocuments:PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed
                                                pollInterval:1.0f];
}

- (void)teardownTableData {
    // this view controller will stop receiving all news about the upload status
    [[PPPhotoPayCloudService sharedService] setUploadDelegate:nil];
}

- (void)setupNotifications {
    // watch for did enter background event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // watch for will enter foreground event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didEnterBackground:(NSNotification *)notification {
    [self teardownTableData];
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self setupTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSString*)defaultXibName {
    if (IS_IPAD) {
        return @"PPHomeViewController_iPad";
    } else {
        return @"PPHomeViewController_iPhone";
    }
}

- (IBAction)cameraButtonPressed:(id)sender {
    [self openCamera];
}

#pragma mark - PPHomeViewControllerProtocol

- (void)openCamera {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    // Use rear camera
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    // Displays a control that allows the user to choose only photos
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for trimming movies.
    cameraUI.allowsEditing = NO;
    
    // Shows default camera control overlay over camera preview.
    // TODO: set this to NO and provide custom overlay
    cameraUI.showsCameraControls = YES;
    
    // set delegate
    cameraUI.delegate = self;
    
    // Show view
    // in iOS7 (as of DP6) this shows a bugged status bar (see https://devforums.apple.com/message/861462#861462)
    // TODO: iOS 6 should be tested
    // iOS5 works OK, just like Facebook app
    [self presentModalViewController:cameraUI animated:YES completion:nil];
}

- (void)openDocumentDetailsView:(PPDocument*)document {
    PPDocumentDetailsViewController* documentDetails = [[PPDocumentDetailsViewController alloc] initWithNibName:[PPDocumentDetailsViewController defaultXibName]
                                                                                                         bundle:nil
                                                                                                       document:document];
    
    [[self navigationController] pushViewController:documentDetails animated:YES];
}

- (void)uploadDocument:(PPLocalDocument *)document {
    // send document to processing server
    [[PPPhotoPayCloudService sharedService] uploadDocument:document
                                                  delegate:self
                                                   success:nil
                                                   failure:nil
                                                  canceled:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        
        // create a local document for this user
        PPLocalDocument *document = [[PPLocalImageDocument alloc] initWithImage:originalImage
                                                                 processingType:PPDocumentProcessingTypeSerbianPhotoInvoice];
        
        [self uploadDocument:document];

    }
    [self dismissModalViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES completion:nil];
}

#pragma mark - PPTableViewDataSourceDelegate

/**
 Called when new items are inserted into table view.
 Method passes the exact index paths of the inserted elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
 didInsertItemsAtIndexPaths:(NSArray*)indexPaths {
    [[self billsTable] beginUpdates];
    [[self billsTable] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self billsTable] endUpdates];
}

/**
 Called when items are deleted from table view.
 Method passes the exact index paths of the deleted elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
 didDeleteItemsAtIndexPaths:(NSArray*)indexPaths {
    [[self billsTable] beginUpdates];
    [[self billsTable] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [[self billsTable] endUpdates];
}

/**
 Called when items are reloaded inside the table view.
 Method passes the exact index paths of the reloaded elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
  didReloadItemsAtIndexPath:(NSArray*)indexPaths {
    [[self billsTable] beginUpdates];
    [[self billsTable] reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self billsTable] endUpdates];
}

/**
 Called when new sections are inserted into table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didInsertSections:(NSIndexSet *)sections {
    [[self billsTable] beginUpdates];
    [[self billsTable] insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self billsTable] endUpdates];
}

/**
 Called when new sections are deleted into table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didDeleteSections:(NSIndexSet *)sections {
    [[self billsTable] beginUpdates];
    [[self billsTable] deleteSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self billsTable] endUpdates];
}

/**
 Called when new sections are reloaded inside the table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didReloadSections:(NSIndexSet *)sections {
    [[self billsTable] beginUpdates];
    [[self billsTable] reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self billsTable] endUpdates];
}


#pragma mark - PPDocumentUploadDelegate

- (void)localDocument:(PPLocalDocument *)localDocument
didUpdateProgressWithBytesWritten:(long long)totalBytesWritten
    totalBytesToWrite:(long long)totalBytesToWrite {
    
    // instead of requesting the whole table to update, we just find the potential cell among visible cells
    for (PPDocumentTableViewCell* cell in self.billsTable.visibleCells) {
        if (cell.document.state == PPDocumentStateUploading) {
            [cell refreshProgress];
        }
    }
}

- (void)localDocumentDidCancelUpload:(PPLocalDocument *)localDocument {
    DDLogInfo(@"Document upload is canceled!");
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PPDocumentTableViewCell defaultHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openDocumentDetailsView:(PPDocument*) [[self documentsDataSource] itemForIndexPath:indexPath]];
}

@end
