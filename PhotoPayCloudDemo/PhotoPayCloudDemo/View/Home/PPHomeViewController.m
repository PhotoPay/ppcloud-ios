//
//  PPHomeViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PPAlertView.h"
#import "PPDocumentTableViewCell+Uploading.h"
#import "PPDocumentDetailsViewController.h"
#import <DDLog.h>
#import "PPDocumentsTableViewController.h"
#import "UIViewController+ContainerViewController.h"

@interface PPHomeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, PPDocumentsTableViewControllerDelegate, PPPagedContentViewControllerDelegate>

@property (nonatomic, strong) PPDocumentsTableViewController* tableViewController;

- (void)uploadDocument:(PPLocalDocument*)document;

@end

@implementation PPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:_(@"PhotoPayHomeTitle")];
    
    // Add table view controller
    _tableViewController = [[PPDocumentsTableViewController alloc] initWithNibName:@"PPDocumentsTableViewController" bundle:nil];
    [_tableViewController setDocumentStates:PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed];
    [_tableViewController setDelegate:self];
    [_tableViewController setPollInterval:@(10.0f)];
    
    // Display it as a child view controller
    [self pp_displayContentController:[self tableViewController]];
    
    // disable take picture button if camera not available (e.g. Simulator)
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [[self cameraButton] setEnabled:NO];
    }
    
    // Add help button
    UIBarButtonItem *helpBarItem = [[UIBarButtonItem alloc] initWithTitle:_(@"PhotoPayHelpButtonTitle")
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(openHelp)];
    self.navigationItem.rightBarButtonItem = helpBarItem;
}

- (void)pp_displayContentController:(UIViewController *)content {
    [super pp_displayContentController:content];
    // besides regular adding of content view to this view-controllers view
    // we want to send the content view to back
    // because Camera Button needs to be in front of everything
    [self.view sendSubviewToBack:content.view];
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

#pragma mark - Basic functionality

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
    [self presentViewController:cameraUI animated:YES completion:nil];
}

- (void)openDocumentDetailsView:(PPDocument*)document {
    PPDocumentDetailsViewController* documentDetails =
        [[PPDocumentDetailsViewController alloc] initWithNibName:[PPDocumentDetailsViewController defaultXibName]
                                                          bundle:nil
                                                        document:document];
    
    [[self navigationController] pushViewController:documentDetails animated:YES];
}

- (void)uploadDocument:(PPLocalDocument *)document {
    // send document to processing server
    [[PPPhotoPayCloudService sharedService] uploadDocument:document
                                                  delegate:[self tableViewController]
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Opening help and callback which closes help

- (void)openHelp {
    PPPagedContentViewController *helpController = [[PPPagedContentViewController alloc] initWithContentsFile:@"helpContent"];
    helpController.delegate = self;
    helpController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    helpController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:helpController animated:YES completion:nil];
}

- (void)pagedViewControllerDidClose:(id)pagedViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PPDocumentsTableViewControllerDelegate

- (void)tableViewController:(id)controller willOpenDetailsForDocument:(PPDocument*)document {
    [self openDocumentDetailsView:document];
}

@end
