//
//  PPDocumentUploadingTableViewCell.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/14/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentUploadingTableViewCell.h"
#import <PhotoPayCloud/PhotoPayCloud.h>
#import "PPAlertView.h"

@implementation PPDocumentUploadingTableViewCell

+ (id)allocWithNibName:(NSString *)name
              document:(PPDocument*)document {
    PPDocumentUploadingTableViewCell* cell = (PPDocumentUploadingTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] objectAtIndex:0];
    
    if (cell) {
        cell.document = document;
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refresh {
    self.uploadProgress.progress = [[[[[self document] localDocument] uploadRequest] progress] floatValue];
}

@end
