//
//  PPHomeTableViewCell.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/14/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPDocument;

@interface PPHomeTableViewCell : UITableViewCell

@property (nonatomic, strong) PPDocument* document;

- (void)refresh;

@end
