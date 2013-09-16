//
//  PPDocumentCreatedTableViewCell.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/15/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeTableViewCell.h"

@interface PPDocumentCreatedTableViewCell : PPHomeTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

/**
 Allocates the cell object from a nib file with given name
 */
+ (id)allocWithNibName:(NSString *)name
              document:(PPDocument*)document;

@end
