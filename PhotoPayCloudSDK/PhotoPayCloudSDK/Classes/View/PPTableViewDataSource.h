//
//  PPTableViewDataSource.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Data source for UITableView with list of items which need to be presented in a table view
 */
@interface PPTableViewDataSource : NSObject <UITableViewDataSource>

/**
 Items of the table view
 */
@property (nonatomic, strong) NSArray* items;

/**
 Defines a section creator which divides items into sections for display inside UITableView
 
 This object must be a subclass of PPTableSectionCreator
 */
@property (nonatomic, strong) id sectionCreator;

/**
 Retrieves an item with indexpath from the data source
 */
- (id)itemForIndexPath:(NSIndexPath*)indexPath;

@end
