//
//  PPHomeTableViewCell.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/14/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPHomeTableViewCell.h"

@implementation PPHomeTableViewCell

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
    // this method should be overriden in subclasses
    // default implementation does nothing
}

@end
