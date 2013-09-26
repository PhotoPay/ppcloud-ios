//
//  PPDocumentDetailsViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotoPayCloud/PhotoPayCloud.h>

@interface PPDocumentDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *documentPreviewView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *documentPreviewActivityIndicator;

@property (nonatomic, strong, readonly) PPDocument* document;

- (IBAction)openPreview:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             document:(PPDocument*)inDocument;

/**
 Loads the default XIB file for this view controller
 */
+ (NSString*)defaultXibName;

@end
