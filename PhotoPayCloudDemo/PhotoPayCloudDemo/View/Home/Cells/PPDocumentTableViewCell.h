//
//  PPDocumentTableViewCell.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/17/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotoPayCloud/PhotoPayCloud.h>

@interface PPDocumentTableViewCell : UITableViewCell

@property (nonatomic, strong) PPDocument* document;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *thumbnailLoadingIndicator;

@property (weak, nonatomic) IBOutlet UILabel *largeLabel;

@property (weak, nonatomic) IBOutlet UILabel *mediumLabel;

@property (weak, nonatomic) IBOutlet UILabel *smallLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

+ (id)allocWithNibName:(NSString *)name;

- (void)refreshWithDocument:(PPDocument*)document;

+ (NSString*)defaultXibName;

+ (CGFloat)defaultHeight;

@end
