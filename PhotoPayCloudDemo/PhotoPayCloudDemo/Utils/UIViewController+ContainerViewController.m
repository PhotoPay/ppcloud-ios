//
//  UIViewController+ContainerViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 08/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "UIViewController+ContainerViewController.h"

@implementation UIViewController (ContainerViewController)

- (CGRect)pp_frameForChildViewController {
    // default implementation uses the whole view's frame
    return self.view.frame;
}

- (void)pp_displayContentController:(UIViewController*)content {
    // We call the container’s addChildViewController: method to add the child.
    // Calling the addChildViewController: method also calls the child’s willMoveToParentViewController:
    // method automatically.
    [self addChildViewController:content];
    
    // We access the child’s view property to retrieve the view and add it to its own view hierarchy.
    // The container sets the child’s size and position before adding the view; containers always
    // choose where the child’s content appears. Although this example does this by explicitly
    // setting the frame, you could also use layout constraints to determine the view’s position
    content.view.frame = [self pp_frameForChildViewController];
    [self.view addSubview:content.view];
    
    // We explicitly call the child’s didMoveToParentViewController:
    // method to signal that the operation is complete.
    [content didMoveToParentViewController:self];
}

- (void)pp_hideContentController: (UIViewController*)content {
    // We call the child’s willMoveToParentViewController: method with a
    // parameter of nil to tell the child that it is being removed.
    [content willMoveToParentViewController:nil];
    
    // We clean up the view hierarchy
    [content.view removeFromSuperview];
    
    // We call the child’s removeFromParentViewController method to remove it from the container.
    // Calling the removeFromParentViewController method automatically calls
    // the child’s didMoveToParentViewController: method
    [content removeFromParentViewController];
}


@end
