//
//  PPDocumentsDataSource.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Data source for UITableView with list of scanned documents
 */
@interface PPDocumentsDataSource : NSObject <UITableViewDataSource>

/**
 Data source wraps it's logic around a list of PPDocument objects. 
 */
@property (nonatomic, strong, setter = setDocuments:) NSArray* documents;

/**
 Retrieves a document with indexoath from the data source 
 */
- (PPDocument*)documentForIndexPath:(NSIndexPath*)indexPath;

@end
