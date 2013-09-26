//
//  PPDocumentTableViewCell.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/17/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell.h"

@implementation PPDocumentTableViewCell

+ (id)allocWithNibName:(NSString *)name {
    PPDocumentTableViewCell* cell = (PPDocumentTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] objectAtIndex:0];
    
    return cell;
}

- (void)refreshWithDocument:(PPDocument*)document {
    [self setDocument:document];
    
    if ([document thumbnailImage] == nil) {
        [self thumbnailView].hidden = YES;
        [self thumbnailLoadingIndicator].hidden = NO;
        [[self thumbnailLoadingIndicator] startAnimating];
        
        [document thumbnailImageWithSuccess:^(UIImage *thumbnailImage) {
            [self thumbnailView].hidden = NO;
            [self thumbnailView].image = thumbnailImage;
            [[self thumbnailLoadingIndicator] stopAnimating];
        } failure:^{
            ;
        }];
    } else {
        [self thumbnailView].hidden = NO;
        [[self thumbnailLoadingIndicator] stopAnimating];
        [self thumbnailView].image = [document thumbnailImage];
    }
}

+ (NSString*)defaultXibName {
    if (IS_IPAD) {
        return @"PPDocumentTableViewCell_iPad";
    } else {
        return @"PPDocumentTableViewCell_iPhone";
    }
}

+ (CGFloat)defaultHeight {
    if (IS_IPAD) {
        return 86.0f;
    } else {
        return 70.0f;
    }
}

@end
