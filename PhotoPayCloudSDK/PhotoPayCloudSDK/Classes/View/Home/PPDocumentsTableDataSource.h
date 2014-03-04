//
//  PPDocumentsTableDataSource.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/16/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableViewDataSource.h"
#import "PPDocument.h"

@interface PPDocumentsTableDataSource : PPTableViewDataSource

@property (nonatomic, assign) PPDocumentState documentStates;

- (void)removeItemsWithUnallowedStates;

@end
