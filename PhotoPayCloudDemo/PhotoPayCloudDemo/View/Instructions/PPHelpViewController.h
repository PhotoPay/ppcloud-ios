//
//  PhotopayHelpViewController.h
//  iphone-photopay
//
//  Created by Ja on 11/10/11.
//  Copyright (c) 2011 jcerovec@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotopayHelpViewControllerDelegate;

@interface PPHelpViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *helpImageView;

@property (retain, nonatomic) IBOutlet UILabel *helpImageLabel;

@end
