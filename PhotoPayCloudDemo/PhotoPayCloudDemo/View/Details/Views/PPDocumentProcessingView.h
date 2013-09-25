//
//  PPDocumentProcessingView.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/25/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDetailsView.h"

@interface PPDocumentProcessingView : PPDocumentDetailsView

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end
