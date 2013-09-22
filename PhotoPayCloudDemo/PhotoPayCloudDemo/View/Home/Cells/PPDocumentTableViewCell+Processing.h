//
//  PPDocumentTableViewCell+Processing.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/20/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell.h"

@interface PPDocumentTableViewCell (Processing)

- (void)refreshWithDocumentInProcessing:(PPRemoteDocument*)remoteDocument;

@end
