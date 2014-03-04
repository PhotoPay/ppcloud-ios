//
//  PPHomeViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeViewController.h"
#import "PPAlertView.h"
#import "PPDocumentTableViewCell+Uploading.h"
#import "PPDocumentDetailsViewController.h"
#import <DDLog.h>
#import "PPDocumentsTableViewController.h"

@interface PPHomeViewController ()

@end

@implementation PPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:_(@"PhotoPayHomeTitle")];
    
    // Add table view controller
    self.tableViewController = [[PPDocumentsTableViewController alloc] initWithNibName:@"PPDocumentsTableViewController" bundle:nil];
    [self.tableViewController setDocumentStates:PPDocumentStateLocal | PPDocumentStateRemoteUnconfirmed];
    [self.tableViewController setDelegate:self];
    [self.tableViewController setPollInterval:@(10.0f)];
    
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

- (void)openDocumentDetailsView:(PPDocument*)document {
    PPDocumentDetailsViewController* documentDetails =
    [[PPDocumentDetailsViewController alloc] initWithNibName:[PPDocumentDetailsViewController defaultXibName]
                                                      bundle:nil
                                                    document:document];
    
    [[self navigationController] pushViewController:documentDetails animated:YES];
}

@end
