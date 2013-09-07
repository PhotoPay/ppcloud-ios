//
//  PPSignUpViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPSignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIdDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)donePressed:(id)sender;
+ (NSString*)defaultXibName;

@end
