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

@interface PPHomeViewController () <UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PPUploadRequestOperationDelegate>

@property (nonatomic, strong) PPDocumentsDataSource* documentsDataSource;

- (void)reloadTableWithDocuments:(NSArray*)documents;
- (void)uploadDocument:(PPLocalDocument*)document;
- (void)refreshDocumentTable;

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
    
    // this view controller will receive all news about the upload status
    [[[PPPhotoPayCloudService sharedService] networkManager] setUploadDelegate:self];
    
    //To clear any selection in the table view before it’s displayed,
    // implement the viewWillAppear: method to clear the selected row
    // (if any) by calling deselectRowAtIndexPath:animated:.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PPDocument *doc1 = [[PPDocument alloc] init];
    PPDocument *doc2 = [[PPDocument alloc] init];
    PPDocument *doc3 = [[PPDocument alloc] init];
    PPDocument *doc4 = [[PPDocument alloc] init];
    PPDocument *doc5 = [[PPDocument alloc] init];
    
    NSArray* documents = [[NSArray alloc] initWithObjects:doc1, doc2, doc3, doc4, doc5, nil];
    
    [self reloadTableWithDocuments:documents];
    
    // flash the scroll view’s scroll indicators
    [[self billsTable] flashScrollIndicators];
    
    // check if PhotoPayCloudService was paused
    if ([[PPPhotoPayCloudService sharedService] state] == PPPhotoPayCloudServiceStatePaused) {
        // if true, ask user to continue or abort paused requests
        
//        [[PPPhotoPayCloudService sharedService] resumeUploadRequests];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // this view controller will receive all news about the upload status
    [[[PPPhotoPayCloudService sharedService] networkManager] setUploadDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableWithDocuments:(NSArray*)documents {
    [[self documentsDataSource] setItems:documents];
    [[self billsTable] reloadData];
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
    DDLogInfo(@"Opening document!");
}

- (void)uploadDocument:(PPLocalDocument *)document {
    // send document to processing server
    [[PPPhotoPayCloudService sharedService] uploadDocument:document
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

- (void)refreshDocumentTable {
    DDLogInfo(@"Refreshing UI");
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

#pragma mark - PPUploadRequestOperationDelegate

- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
             didUploadDocument:(PPLocalDocument *)localDocument
                    withResult:(PPRemoteDocument *)remoteDocument {
    DDLogInfo(@"Document is successfully uploaded!");

}

- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
       didFailToUploadDocument:(PPLocalDocument *)localDocument
                     withError:(NSError *)error {
    DDLogError(@"Document has failed to upload!");
    DDLogError(@"Error message is %@", [error localizedDescription]);
    
    PPAlertView *alertView = [[PPAlertView alloc] initWithTitle:@"Upload could not be completed"
                                                        message:@"Would you like to try again?"
                                                     completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                            if (buttonIndex == 1) { // retry button
                                                                // enqueue this upload once more
                                                                [self uploadDocument:localDocument];
                                                            }
                                                        }
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Try again", nil];
    [alertView show];
}

- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
  didUpdateProgressForDocument:(PPLocalDocument *)localDocument
             totalBytesWritten:(long long)totalBytesWritten
             totalBytesToWrite:(long long)totalBytesToWrite {
    DDLogInfo(@"Document is uploading. Progress is %.2f!", 100 * totalBytesWritten / (double)totalBytesToWrite);
}

- (void)uploadRequestOperation:(id<PPUploadRequestOperation>)operation
    didCancelUploadingDocument:(PPLocalDocument *)localDocument {
    DDLogInfo(@"Document upload is canceled!");

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openDocumentDetailsView:(PPDocument*) [[self documentsDataSource] itemForIndexPath:indexPath]];
    [[self billsTable] deselectRowAtIndexPath:indexPath animated:YES];
}

@end
