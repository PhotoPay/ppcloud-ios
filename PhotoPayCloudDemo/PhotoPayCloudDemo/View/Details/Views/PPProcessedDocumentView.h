//
//  PPProcessedDocumentView.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDetailsView.h"

@interface PPProcessedDocumentView : PPDocumentDetailsView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

@property (weak, nonatomic) IBOutlet UILabel *referenceLabel;

@property (weak, nonatomic) IBOutlet UITextField *referenceTextField;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *payButton;

@end
