//
//  PPDocumentDetailsViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDetailsViewController.h"
#import "PPDocumentViewFactory.h"
#import "PPDocumentDetailsView.h"
#import "PPDocumentPreview.h"

@interface PPDocumentDetailsViewController () <PPDocumentDetailsViewDelegate, PPDocumentStateChangedDelegate>

@property (nonatomic, strong) PPDocumentViewFactory* viewFactory;

@property (nonatomic, strong) PPDocumentDetailsView* documentView;

- (CGRect)frameForDocumentView:(UIView*)documentView;

@end

@implementation PPDocumentDetailsViewController

@synthesize document;
@synthesize viewFactory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithNibName:bundle:document` instead.", NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             document:(PPDocument*)inDocument
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        document = inDocument;
        viewFactory = [[PPDocumentViewFactory alloc] initWithDocument:inDocument];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([[self document] previewImage] == nil) {
        // if a preview image doesn't exist
        
        // if thumbnail image exists, set it as a placeholder
        if ([[self document] thumbnailImage] != nil) {
            [self documentPreviewView].image = [[self document] thumbnailImage];
        }
        
        // show loading indicator
        [[self documentPreviewActivityIndicator] startAnimating];
        
        // present preview image asynchronously
        [[self document] previewImageWithSuccess:^(UIImage *previewImage) {
            [self documentPreviewView].image = previewImage;
            [[self documentPreviewActivityIndicator] stopAnimating];
        } failure:^(){
            [[self documentPreviewActivityIndicator] stopAnimating];
        }];
        
    } else {
        // if we have preview image available, present it synchronously
        [self documentPreviewView].image = [[self document] previewImage];
    }
    
    [self showDetailsViewForDocument:[self document] animated:NO];
    
    if (!IS_IOS7_DEVICE) {
        [self setWantsFullScreenLayout:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.documentView setDocument:[self document]];
    [[self document] setDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.documentView setDocument:nil];
    [[self document] setDelegate:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.documentView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openPreview:(id)sender {
    QLPreviewController *qlpvc = [[QLPreviewController alloc] init];
    
    PPDocumentPreview* documentPreview = [[PPDocumentPreview alloc] initWithDocument:[self document] forController:qlpvc];
    qlpvc.dataSource = documentPreview;
    
    //[self presentModalViewController:qlpvc animated:YES];
    [self.navigationController pushViewController:qlpvc animated:YES];
}

+ (NSString*)defaultXibName {
    if (IS_IPAD) {
        return @"PPDocumentDetailsViewController_iPhone";
    } else {
        return @"PPDocumentDetailsViewController_iPhone";
    }
}

- (CGRect)frameForDocumentView:(UIView*)documentView {
    CGRect frame = [documentView frame];
    frame.origin.y = self.documentPreviewView.frame.origin.y + self.documentPreviewView.frame.size.height;
    frame.origin.x = 0;
    frame.size.width = self.view.frame.size.width;
    
    documentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return frame;
}

#pragma mark - PPDocumentDetailsViewDelegate

- (void)documentDidChangeState:(PPDocument*)inDocument {
    [self showDetailsViewForDocument:inDocument animated:YES];
}

- (void)showDetailsViewForDocument:(PPDocument*)inDocument animated:(BOOL)animated {
    static CGFloat duration = 0.25f;
    
    void (^showBlock)(BOOL) = ^(BOOL finished) {
        // set hidden
        self.documentView = [[self viewFactory] documentViewForDocumentState:[[self document] state]];
        self.documentView.frame = [self frameForDocumentView:self.documentView];
        self.documentView.delegate = self;
        [[self view] addSubview:self.documentView];
	};
    
    if (!animated) {
        showBlock(YES);
    } else {
        [UIView animateWithDuration:duration
                         animations:^{
                             self.documentView.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             showBlock(finished);
                             self.documentView.alpha = 0.0f;
                             [UIView animateWithDuration:duration
                                              animations:^{
                                                  self.documentView.alpha = 1.0f;
                                              } completion:nil];
                         }];
    };
}

#pragma mark - PPDocumentDetailsViewDelegate

- (void)documentDetailsViewWillClose:(PPDocumentDetailsView*)detailsView {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
