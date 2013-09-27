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
#import "PPQLPreviewController.h"

@interface PPDocumentDetailsViewController () <PPDocumentDetailsViewDelegate, PPDocumentStateChangedDelegate>

@property (nonatomic, strong) PPDocumentViewFactory* viewFactory;

@property (nonatomic, strong) PPDocumentDetailsView* documentView;

@property (nonatomic, strong) UIView* activeField;

- (CGRect)frameForDocumentView:(UIView*)documentView;

@end

@implementation PPDocumentDetailsViewController

@synthesize document;
@synthesize viewFactory;
@synthesize activeField;

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
    
    [self setTitle:_(@"PhotoPayDetailsViewTitle")];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.documentView setDocument:[self document]];
    [[self document] setDelegate:self];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.documentView setDocument:nil];
    [[self document] setDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
    
    self.documentView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openPreview:(id)sender {
    PPQLPreviewController *qlpvc = [[PPQLPreviewController alloc] init];
    
    PPDocumentPreview* documentPreview = [[PPDocumentPreview alloc] initWithDocument:[self document] forController:qlpvc];
    qlpvc.documentPreview = documentPreview;
    
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
    frame.size.width = self.scrollView.frame.size.width;
    
    documentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return frame;
}

#pragma mark - Keyboard methods

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, keyboardSize.height, 0.0f);
//    UIEdgeInsets a = UIEdgeInsetsMa
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    
    CGPoint activeFieldOrigin = activeField.frame.origin;
    activeFieldOrigin.x += self.documentView.frame.origin.x;
    activeFieldOrigin.y += self.documentView.frame.origin.y;
    
    if (!CGRectContainsPoint(aRect, activeFieldOrigin) ) {
        CGPoint scrollPoint = CGPointMake(0.0f, activeFieldOrigin.y - keyboardSize.height + 64.0f); // offset for navbar and status bar
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
}

#pragma mark - PPDocumentDetailsViewDelegate

- (void)documentDidChangeState:(PPDocument*)inDocument {
    [[self document] setDelegate:nil];
    document = inDocument;
    [[self document] setDelegate:self];
    [[self viewFactory] setDocument:document];
    [self showDetailsViewForDocument:inDocument animated:YES];
}

- (void)showDetailsViewForDocument:(PPDocument*)inDocument animated:(BOOL)animated {
    static CGFloat duration = 0.25f;
    
    void (^showBlock)(BOOL) = ^(BOOL finished) {
        // set hidden
        self.documentView = [[self viewFactory] documentView];
        self.documentView.frame = [self frameForDocumentView:self.documentView];
        self.documentView.delegate = self;
        [[self scrollView] addSubview:self.documentView];
        [[self scrollView] setContentSize:CGSizeMake(self.documentView.frame.size.width, self.documentView.frame.size.height + self.documentView.frame.origin.y)];
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

- (void)documentDetailsView:(PPDocumentDetailsView*)detailsView
          didMakeViewActive:(UIView*)activeView {
    self.activeField = activeView;
}

- (void)documentDetailsViewDidMakeViewInactive:(PPDocumentDetailsView*)detailsView {
    self.activeField = nil;
}

@end
