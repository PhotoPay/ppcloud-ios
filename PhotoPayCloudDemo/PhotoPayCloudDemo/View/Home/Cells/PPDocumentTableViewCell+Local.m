//
//  PPDocumentTableViewCell+Local.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell+Local.h"

@implementation PPDocumentTableViewCell (Local)

- (void)refreshWithLocalDocument:(PPLocalDocument*)localDocument {
    [self refreshWithDocument:localDocument];
    
    [self largeLabel].hidden = YES;
    [self mediumLabel].hidden = NO;
    [self smallLabel].hidden = YES;
    [self progressView].hidden = YES;
}

@end
