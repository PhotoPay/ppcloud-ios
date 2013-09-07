//
//  PPDocumentTableViewCell.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A cell for displaying one scanned document, i.e. PPDocument object
 */
@interface PPDocumentTableViewCell : UITableViewCell

/**
 Displays a thumbnail of the document
 */
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

/**
 Displays the amount scanned in the document
 */
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

/**
 Displays the receiver of the payment from the scanned document. 
 Either name (if known) or account number is displayed.
 */
@property (weak, nonatomic) IBOutlet UILabel *receiverLabel;

/**
 Displys the reference of the payment from the scanned document.
 */
@property (weak, nonatomic) IBOutlet UILabel *referenceLabel;

/**
 Allocates the cell object from a nib file with given name
 */
+ (id)allocWithNibName:(NSString *)name;

@end
