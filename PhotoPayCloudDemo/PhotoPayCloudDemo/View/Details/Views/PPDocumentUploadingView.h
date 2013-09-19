//
//  PPDocumentUploadingView.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDetailsView.h"

@interface PPDocumentUploadingView : PPDocumentDetailsView<PPDocumentUploadDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusMessage;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *stopSendingButton;

- (IBAction)cancelSend:(id)sender;

- (IBAction)deleteDocument:(id)sender;

@end
