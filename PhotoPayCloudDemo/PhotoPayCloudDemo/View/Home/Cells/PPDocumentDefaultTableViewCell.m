//
//  PPDocumentDefaultTableViewCell.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/17/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentDefaultTableViewCell.h"

@implementation PPDocumentDefaultTableViewCell

+ (id)allocWithNibName:(NSString *)name
              document:(PPDocument*)document {
    PPDocumentDefaultTableViewCell* cell = (PPDocumentDefaultTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] objectAtIndex:0];
    
    if (cell) {
        cell.document = document;
    }
    
    return cell;
}

@end
