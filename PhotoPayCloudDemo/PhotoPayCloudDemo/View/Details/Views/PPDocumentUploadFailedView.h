//
//  PPDocumentUploadFailedView.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDetailsView.h"

@interface PPDocumentUploadFailedView : PPDocumentDetailsView

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *resendButton;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)deletePressed:(id)sender;

- (IBAction)resendPressed:(id)sender;

@end
