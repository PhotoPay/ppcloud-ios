//
//  PagedContentViewController.h
//  iphone-photopay
//
//  Created by Ja on 11/11/11.
//  Copyright (c) 2011 jcerovec@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPPagedContentViewControllerDelegate;
@class PPStyledPageControl;

/**
 * Responsible for showing multiple pages that can be scrolled
 */
@interface PPPagedContentViewController : UIViewController<UIScrollViewDelegate> 

@property (nonatomic, retain) NSString* contentsFile;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) PPStyledPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) id<PPPagedContentViewControllerDelegate> delegate;

- (id)initWithContentsFile:(NSString*)contentsFile;

- (void)changePage:(id)sender;

@end

@protocol PPPagedContentViewControllerDelegate

- (void)pagedViewControllerDidClose:(id)pagedViewController;

@end
