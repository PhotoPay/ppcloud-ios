//
//  PPDocumentTableViewCell.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell.h"

@implementation PPDocumentTableViewCell

+ (id)allocWithNibName:(NSString *)name {
    PPDocumentTableViewCell* cell = (PPDocumentTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] objectAtIndex:0];
    
    if (cell) {
        // Initialization code
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

@end
