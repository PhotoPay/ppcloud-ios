//
//  PPSignUpViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This object controls views which user sees when sign up is required. This happens on first start of application
 */
@interface PPSignUpViewController : UIViewController

/**
 Loads the default XIB file for this view controller
 */
+ (NSString*)defaultXibName;

/**
 Text field for entering user id (e.g. e-mail)
 */
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

/**
 Label in which the instruction to the user is displayed
 */
@property (weak, nonatomic) IBOutlet UILabel *userIdDescriptionLabel;

/**
 Label in which the status of entered user ID is displayed. E.g, User ID is invalid, already exists, etc.
 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

/**
 Done button is located in the navigation bar
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

/**
 Title of the view
 */
@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;

/**
 Navigation bar in which the title and done button is placed
 */
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

/**
 Callback on done button pressed
 */
- (IBAction)donePressed:(id)sender;

@end
