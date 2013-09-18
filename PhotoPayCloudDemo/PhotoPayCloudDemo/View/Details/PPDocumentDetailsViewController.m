//
//  PPDocumentDetailsViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDetailsViewController.h"

@interface PPDocumentDetailsViewController ()

@end

@implementation PPDocumentDetailsViewController

@synthesize document;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithNibName:bundle:document` instead.", NSStringFromClass([self class])] userInfo:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             document:(PPDocument*)inDocument;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        document = inDocument;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self documentPreviewActivityIndicator] startAnimating];
    
    [[self document] previewImageWithSuccess:^(UIImage *previewImage) {
        [self documentPreviewView].image = previewImage;
        [[self documentPreviewActivityIndicator] stopAnimating];
    } failure:^{
        ;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSString*)defaultXibName {
    if (IS_IPAD) {
        return @"PPDocumentUploadingViewController_iPhone";
    } else {
        return @"PPDocumentUploadingViewController_iPhone";
    }
}

@end
