//
//  PagedContentViewController.m
//  iphone-photopay
//
//  Created by Ja on 11/11/11.
//  Copyright (c) 2011 jcerovec@gmail.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PPPagedContentViewController.h"
#import "PPStyledPageControl.h"
#import "PPHelpViewController.h"
#import "NSString+Size.h"
#import "PPApp.h"

static NSString *nameKey    = @"nameKey";
static NSString *imageKey   = @"imageKey";

#define pageIndicatorColor          ([UIColor colorWithRed:128/255.0 green:130/255.0 blue:133/255.0 alpha:1])
#define pageIndicatorDarkerColor    ([UIColor colorWithRed:128/255.0*0.6 green:130/255.0*0.6 blue:133/255.0*0.6 alpha:1])
#define pageIndicatorHeight         (28.0f)

#define helpBarButtonHeight         (28.0f)
#define helpBarButtonWidth          (90.0f)
#define helpBarButtonMargin         ((heightToolbar - helpBarButtonHeight) / 2)
#define helpBarButtonFont           ([UIFont boldSystemFontOfSize:14.0f])
#define helpBarButtonTextColor      ([UIColor colorWithRed:1 green:1 blue:1 alpha:1])

#define buttonRedColor              ([UIColor colorWithRed:0.77 green:0.1 blue:0.18 alpha:1])
#define buttonRedDarkerColor        ([UIColor colorWithRed:0.77*0.6 green:0.1*0.6 blue:0.18*0.6 alpha:1])
#define buttonGrayColor             ([UIColor colorWithWhite:0.5 alpha:1])
#define buttonGrayDarkerColor       ([UIColor colorWithRed:128/255.0*0.6 green:130/255.0*0.6 blue:133/255.0*0.6 alpha:1])
#define buttonBorderColor           ([UIColor colorWithWhite:0.1 alpha:0.4])

#define buttonAnimationDuration     (0.3f)

#define heightToolbar               (44.0f)

#define helpImageLabelMargin        (helpBarButtonMargin)
#define helpImageScaleFactor        (1.0f)

@interface PPPagedContentViewController ()

@property (retain, nonatomic) UIButton* backButton;
@property (retain, nonatomic) UIButton* forwardButton;
@property (nonatomic, retain) UIImageView* backImage;
@property (nonatomic, retain) UIImageView* forwardImage;

@property (nonatomic, retain) NSArray *contentList;

@property (nonatomic, assign) NSUInteger numberOfPages;

@property (nonatomic, assign) BOOL pageControlUsed;

@end

@implementation PPPagedContentViewController

- (id)initWithContentsFile:(NSString*)contentsFile {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _contentsFile = contentsFile;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self view].autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    // load our data from a plist file inside our app bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:[self contentsFile] ofType:@"plist"];
    [self setContentList:[NSArray arrayWithContentsOfFile:path]];
    [self setNumberOfPages: [[self contentList] count]];
    
    /** Setup back button */
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [_backButton setFrame:CGRectMake(helpBarButtonMargin, helpBarButtonMargin, helpBarButtonWidth, helpBarButtonHeight)];
    [self.view addSubview:_backButton];
    
    [self setupBackButtonForPage:0];
    
    _backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left.png"]];
    _backImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [_backImage setFrame:_backButton.frame];
    [_backImage setContentMode:UIViewContentModeLeft];
    [_backImage setAlpha:0.0f];
    [self.view addSubview:_backImage];
    
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [_forwardButton setFrame:CGRectMake(self.view.frame.size.width-helpBarButtonMargin-helpBarButtonWidth, helpBarButtonMargin, helpBarButtonWidth, helpBarButtonHeight)];
    [self.view addSubview:_forwardButton];
    
    [self setupForwardButtonForPage:0];
    
    _forwardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]];
    _forwardImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [_forwardImage setFrame:_forwardButton.frame];
    [_forwardImage setContentMode:UIViewContentModeRight];
    [_forwardImage setAlpha:0.0f];
    [self.view addSubview:_forwardImage];
    
    /** Page Control Setup */
    _pageControl = [[PPStyledPageControl alloc] initWithFrame:CGRectMake(0,
                                                                         self.view.bounds.size.height - pageIndicatorHeight,
                                                                         self.view.bounds.size.width,
                                                                         pageIndicatorHeight)];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [_pageControl setNumberOfPages:[self numberOfPages]];
    [_pageControl setCurrentPage:0];
    [_pageControl setDiameter:10];
    [_pageControl setCoreNormalColor:pageIndicatorColor];
    [_pageControl setCoreSelectedColor:pageIndicatorDarkerColor];
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_pageControl];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    
    for (unsigned i = 0; i < _numberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    [self setViewControllers:controllers];
    
    /** Scroll view init */
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, heightToolbar,
                                                                 self.view.bounds.size.width,
                                                                 self.view.bounds.size.height - heightToolbar - pageIndicatorHeight)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // a page is the width of the scroll view
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    _scrollView.alwaysBounceVertical = NO;
    
    [self.view addSubview:_scrollView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _numberOfPages, _scrollView.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // pages are created on demand
    // load the visible page, and pages on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!IS_IOS7_DEVICE) {
        [[PPApp sharedApp] pushStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!IS_IOS7_DEVICE) {
        [[PPApp sharedApp] popStatusBarStyle];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[self pageControl] removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self setPageControl:nil];
    
    [self scrollView].delegate = nil;
    [self setScrollView:nil];
}

- (void)dealloc {
    [_pageControl removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    _scrollView.delegate = nil;
}

#ifdef IS_IOS7_SDK
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
#endif

#ifdef IS_IOS7_SDK
- (BOOL)prefersStatusBarHidden {
    return (IS_IOS7_DEVICE);
}
#endif

#pragma mark - Autorotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Scrolling

- (void)loadScrollViewWithPage:(NSInteger)page {
    if (page < 0) {
        return;
    }
    
    if (page >= _numberOfPages) {
        return;
    }
    
    // replace the placeholder if necessary
    PPHelpViewController *controller = [_viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[PPHelpViewController alloc] initWithNibName:@"PPHelpViewController"
                                                            bundle:[NSBundle mainBundle]];
        [_viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view. Perform manual layouting.
    if ([[controller view] superview] == nil) {
        
        // set controller.view frame
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        // load image and label text
        NSDictionary *numberItem = [self.contentList objectAtIndex:page];
        UIImage *img = [UIImage imageNamed:[numberItem valueForKey:imageKey]];
        NSString *labelText = _([numberItem valueForKey:nameKey]);
        
        [[controller helpImageLabel] setText:labelText];
        
        CGFloat maxHeight = _scrollView.frame.size.height;
        
        CGFloat maxLabelHeight = 4.5f * [[controller helpImageLabel].font pointSize];
        
        CGFloat textMargin = helpImageLabelMargin;
        CGFloat maxLabelWidth = _scrollView.bounds.size.width - 2 * textMargin;
        
        CGFloat fontSize = [[[controller helpImageLabel] text] pp_fontSizeWithFont:[[controller helpImageLabel] font]
                                                                 constrainedToSize:CGSizeMake(maxLabelWidth, maxLabelHeight)];
        UIFont *resizedFont = [[[controller helpImageLabel] font] fontWithSize:fontSize];
        
        CGSize textSize = [[[controller helpImageLabel] text] sizeWithFont:resizedFont
                                                         constrainedToSize:CGSizeMake(maxLabelWidth, maxLabelHeight)
                                                            lineBreakMode:[controller helpImageLabel].lineBreakMode];
        CGFloat minMargin = helpBarButtonMargin;
        if (minMargin < 16) {
            minMargin = 16;
        }
        CGFloat maxImageHeight = maxHeight - 2.5 * minMargin - textSize.height;
        if (maxImageHeight > maxHeight * 0.6) {
            maxImageHeight = maxHeight * 0.6;
        }
        
        CGFloat maxImageWidth = _scrollView.frame.size.width - 2 * minMargin;
        
        // size and position accordingly
        CGRect imageFrame = CGRectMake(0, 0, img.size.width * helpImageScaleFactor, img.size.height * helpImageScaleFactor);
        
        // scale image so that
        if (imageFrame.size.height > maxImageHeight) {
            CGFloat aspectRatio = imageFrame.size.height / imageFrame.size.width;
            CGFloat width = maxImageHeight / aspectRatio;
            imageFrame = CGRectMake(0, 0, width, maxImageHeight);
        }
        
        if (imageFrame.size.width > maxImageWidth) {
            CGFloat aspectRatio = imageFrame.size.height / imageFrame.size.width;
            CGFloat height = maxImageWidth * aspectRatio;
            imageFrame = CGRectMake(0, 0, maxImageWidth, height);
        }
        
        [[controller helpImageView] setContentMode:UIViewContentModeScaleAspectFit];
        [[controller helpImageView] setImage:img];
        
        CGFloat marginTotal = maxHeight - textSize.height - imageFrame.size.height;
        CGFloat marginElement = marginTotal / 2.5;
        
        [[controller helpImageView] setFrame:CGRectMake((_scrollView.frame.size.width - imageFrame.size.width) / 2, marginElement, imageFrame.size.width, imageFrame.size.height)];
        
        CGFloat labelYPosition = [controller helpImageView].frame.origin.y + [controller helpImageView].frame.size.height + marginElement / 2;
        CGFloat labelXPosition = roundf((_scrollView.frame.size.width - textSize.width) / 2);
        [[controller helpImageLabel] setFrame:CGRectMake(labelXPosition, labelYPosition, textSize.width, textSize.height)];
        [[controller helpImageLabel] setFont:resizedFont];
        
        [_scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    
    if (_pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page != _pageControl.currentPage) {
        [self setupBackButtonForPage:page];
        [self setupForwardButtonForPage:page];
        
        _pageControl.currentPage = page;
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (void)changePage:(id)sender {
    NSInteger page = _pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // setup buttons for current page
    [self setupBackButtonForPage:page];
    [self setupForwardButtonForPage:page];
    
	// update the scroll view to the appropriate page
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}

#pragma mark - button design

- (void)setupBackButtonForPage:(NSInteger)page {
    [_backButton removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    
    [_backButton addTarget:self action:@selector(backTouched) forControlEvents:UIControlEventTouchDown];
    [_backButton titleLabel].layer.shadowRadius = 0.3;
    [_backButton titleLabel].layer.shadowOpacity = 0.6;
    [_backButton titleLabel].layer.shadowColor = [UIColor blackColor].CGColor;
    [_backButton titleLabel].layer.shadowOffset = CGSizeMake(0, -0.4);
    [[_backButton titleLabel] setFont:helpBarButtonFont];
    [_backButton setTitleColor:helpBarButtonTextColor forState:UIControlStateNormal];
    [[_backButton layer] setCornerRadius:4.0f];
     [_backButton setContentMode:UIViewContentModeLeft];
    
    if (page <= 0) {
        [_backButton setTitle:_(@"PhotoPayHelpClose") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(closeHelp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    } else {
        [_backButton setTitle:nil forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(previousPage) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_backButton titleLabel].layer.shadowRadius = 0.0;
        [_backButton titleLabel].layer.shadowOpacity = 0.0;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:buttonAnimationDuration];
    
    if (page <= 0) {
        [_backImage setAlpha:0.0f];
        [_backButton setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [[_backButton layer] setBorderWidth:1.0f];
        [[_backButton layer] setBorderColor:[UIColor colorWithWhite:0.1 alpha:0.4].CGColor];
    } else {
        [_backImage setAlpha:0.6f];
        [_backButton setBackgroundColor:[UIColor clearColor]];
        [[_backButton layer] setBorderWidth:0.0f];
        [[_backButton layer] setBorderColor:[UIColor clearColor].CGColor];
    }
    
    [UIView commitAnimations];
}

- (void)setupForwardButtonForPage:(NSInteger)page {
    [_forwardButton removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
    
    [_forwardButton addTarget:self action:@selector(forwardTouched) forControlEvents:UIControlEventTouchDown];
    [_forwardButton setTitleColor:helpBarButtonTextColor forState:UIControlStateNormal];
    [[_forwardButton titleLabel] setFont:helpBarButtonFont];
    [_forwardButton titleLabel].layer.shadowRadius = 0.3;
    [_forwardButton titleLabel].layer.shadowOpacity = 0.6;
    [_forwardButton titleLabel].layer.shadowColor = [UIColor blackColor].CGColor;
    [_forwardButton titleLabel].layer.shadowOffset = CGSizeMake(0, -0.4);
    [[_forwardButton layer] setCornerRadius:4.0f];
    [_forwardButton setContentMode:UIViewContentModeRight];
    
    if (page <= 0) {
        [_forwardButton setTitle:_(@"PhotoPayHelpContinue") forState:UIControlStateNormal];
        [_forwardButton addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    } else if (page >= [self numberOfPages] - 1) {
        [_forwardButton setTitle:_(@"PhotoPayHelpClose") forState:UIControlStateNormal];
        [_forwardButton addTarget:self action:@selector(closeHelp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    } else {
        [_forwardButton setTitle:nil forState:UIControlStateNormal];
        [_forwardButton addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_forwardButton titleLabel].layer.shadowRadius = 0.0;
        [_forwardButton titleLabel].layer.shadowOpacity = 0.0;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:buttonAnimationDuration];
    
    if (page <= 0 || page >= [self numberOfPages] - 1) {
        [_forwardImage setAlpha:0.0f];
        [_forwardButton setBackgroundColor:buttonRedColor];
        [[_forwardButton layer] setBorderWidth:1.0f];
        [[_forwardButton layer] setBorderColor:[UIColor colorWithWhite:0.1 alpha:0.4].CGColor];
    } else {
        [_forwardImage setAlpha:0.6f];
        [_forwardButton setBackgroundColor:[UIColor clearColor]];
        [[_forwardButton layer] setBorderWidth:0.0f];
        [[_forwardButton layer] setBorderColor:[UIColor clearColor].CGColor];
    }
    
    [UIView commitAnimations];
}

#pragma mark - button callbacks

- (void)closeHelp:(id)sender {
    [[self delegate] pagedViewControllerDidClose:self];
}

- (void)previousPage {
    if (_pageControl.currentPage > 0) {
        _pageControl.currentPage = _pageControl.currentPage - 1;
        [self changePage:nil];
    }
}

- (void)nextPage {
    if (_pageControl.currentPage < _numberOfPages - 1) {
        _pageControl.currentPage = _pageControl.currentPage + 1;
    } else {
        _pageControl.currentPage = 0;
    }
    [self changePage:nil];
}

- (void)forwardTouched {
    if ([_forwardImage alpha] < 0.01) {
        [_forwardButton setBackgroundColor:buttonRedDarkerColor];
    } else {
        [_forwardImage setAlpha:1.0];
    }
}

- (void)backTouched {
    if ([_backImage alpha] < 0.01) {
        [_backButton setBackgroundColor:pageIndicatorDarkerColor];
    } else {
        [_backImage setAlpha:1.0];
    }
}

@end
