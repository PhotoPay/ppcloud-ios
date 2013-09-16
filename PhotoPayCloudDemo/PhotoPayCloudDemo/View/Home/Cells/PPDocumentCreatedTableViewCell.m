//
//  PPDocumentCreatedTableViewCell.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/15/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentCreatedTableViewCell.h"

@implementation PPDocumentCreatedTableViewCell

+ (id)allocWithNibName:(NSString *)name
              document:(PPDocument*)document {
    PPDocumentCreatedTableViewCell* cell = (PPDocumentCreatedTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] objectAtIndex:0];
    
    if (cell) {
        cell.document = document;
    }
    
    return cell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
