//
//  PPBaseHomeViewController.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 04/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPBaseHomeViewController.h"
#import <PPBaseDocumentsTableViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PPLocalImageDocument.h"

@interface PPBaseHomeViewController ()

@property (nonatomic, assign, getter = isTableViewDisplayed) BOOL tableViewDisplayed;

@end

@implementation PPBaseHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTableViewDisplayed:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Display it as a child view controller
    if (![self isTableViewDisplayed]) {
        [self pp_displayContentController:[self tableViewController]];
        [self setTableViewDisplayed:YES];
    }
}

- (void)pp_displayContentController:(UIViewController *)content {
    [super pp_displayContentController:content];
    // besides regular adding of content view to this view-controllers view
    // we want to send the content view to back
    // because Camera Button needs to be in front of everything
    [self.view sendSubviewToBack:content.view];
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
    PPLogError(@"Opening document details view for document %@", document);
}

- (void)uploadImage:(UIImage*)image {
    
    // create a local document for this user
    PPLocalDocument *document = [[PPLocalImageDocument alloc] initWithImage:image
                                                             processingType:PPDocumentProcessingTypeSerbianPhotoInvoice];
    
    [self uploadDocument:document];
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
        UIImage *originalImage = (UIImage *)[info objectForKey: UIImagePickerControllerOriginalImage];
        [self uploadImage:originalImage];
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
