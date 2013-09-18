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

@interface PPHomeViewController () <UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PPDocumentUploadDelegate, PPTableViewDataSourceDelegate>

@property (nonatomic, strong) PPDocumentsDataSource* documentsDataSource;

- (void)uploadDocument:(PPLocalDocument*)document;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:_(@"PhotoPayHomeTitle")];
    
    documentsDataSource = [[PPDocumentsDataSource alloc] init];
    [documentsDataSource setSectionCreator:[[PPTableLinearSectionCreator alloc] init]];
    [documentsDataSource setDelegate:self];
    
    [[PPPhotoPayCloudService sharedService] setDataSource:documentsDataSource];
    [[self billsTable] setDataSource:[self documentsDataSource]];
    [[self billsTable] setDelegate:self];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [[self cameraButton] setEnabled:NO];
    }
}

- (void)viewDidUnload {
    [self setDocumentsDataSource:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self documentsDataSource] setUploadDelegate:self];
    [[PPPhotoPayCloudService sharedService] setUploadDelegate:self];
    
    //To clear any selection in the table view before it’s displayed,
    // implement the viewWillAppear: method to clear the selected row
    // (if any) by calling deselectRowAtIndexPath:animated:.
    
    
    [[PPPhotoPayCloudService sharedService] requestDocuments:PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // flash the scroll view’s scroll indicators
    [[self billsTable] flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // this view controller will receive all news about the upload status
    [[self documentsDataSource] setUploadDelegate:nil];
    [[PPPhotoPayCloudService sharedService] setUploadDelegate:nil];
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
//    PPDocumentDetailsViewController* documentDetails = [[PPDocumentDetailsViewController alloc] initWithNibName:[PPDocumentDetailsViewController defaultXibName]
//                                                                                                         bundle:nil];
//    
//    // make the transition smoother
//    [[self documentsDataSource] setUploadDelegate:nil];
//    [[PPPhotoPayCloudService sharedService] setUploadDelegate:nil];
//    
//    [[self navigationController] pushViewController:documentDetails animated:YES];
}

- (void)uploadDocument:(PPLocalDocument *)document {
    // send document to processing server
    [[PPPhotoPayCloudService sharedService] uploadDocument:document
                                                  delegate:self
                                                   success:^(PPLocalDocument *localDocument, PPRemoteDocument *remoteDocument) {
                                                       NSLog(@"Success!");
                                                   }
                                                   failure:^(PPLocalDocument *localDocument, NSError *error) {
                                                       NSLog(@"Failure!");
                                                   }
                                                  canceled:^(PPLocalDocument *localDocument) {
                                                      NSLog(@"Canceled!");
                                                  }];
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
    [[self billsTable] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
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


#pragma mark - PPUploadRequestOperationDelegate

- (void)localDocument:(PPLocalDocument *)localDocument
didFinishUploadWithResult:(PPRemoteDocument *)remoteDocument {
    DDLogInfo(@"Document is successfully uploaded!");

}

- (void)localDocument:(PPLocalDocument *)localDocument
didFailToUploadWithError:(NSError *)error {
    DDLogError(@"Document has failed to upload!");
    DDLogError(@"Error message is %@", [error localizedDescription]);
}

- (void)localDocument:(PPLocalDocument *)localDocument
didUpdateProgressWithBytesWritten:(long long)totalBytesWritten
    totalBytesToWrite:(long long)totalBytesToWrite {
    
//    NSLog(@"Update %@ progress: %f", [localDocument url], totalBytesWritten / (double)totalBytesToWrite);
    
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
    [[self billsTable] deselectRowAtIndexPath:indexPath animated:YES];
}

@end
