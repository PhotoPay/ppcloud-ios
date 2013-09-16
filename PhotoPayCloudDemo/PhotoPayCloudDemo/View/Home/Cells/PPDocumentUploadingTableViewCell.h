//
//  PPDocumentUploadingTableViewCell.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/14/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPHomeTableViewCell.h"

@interface PPDocumentUploadingTableViewCell : PPHomeTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgress;

/**
 Allocates the cell object from a nib file with given name
 */
+ (id)allocWithNibName:(NSString *)name
              document:(PPDocument*)document;

@end
