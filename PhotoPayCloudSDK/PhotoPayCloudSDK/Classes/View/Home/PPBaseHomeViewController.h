//
//  PPBaseHomeViewController.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 04/03/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPagedContentViewController.h"
#import "PPBaseDocumentsTableViewController.h"
#import "UIViewController+ContainerViewController.h"

@class PPLocalDocument;
@class PPBaseDocumentsTableViewController;

@interface PPBaseHomeViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, PPDocumentsTableViewControllerDelegate, PPPagedContentViewControllerDelegate>

@property (nonatomic, strong) PPBaseDocumentsTableViewController* tableViewController;

- (void)openCamera;

- (void)openHelp;

- (void)uploadImage:(UIImage*)image;

- (void)uploadDocument:(PPLocalDocument *)document;

@end
