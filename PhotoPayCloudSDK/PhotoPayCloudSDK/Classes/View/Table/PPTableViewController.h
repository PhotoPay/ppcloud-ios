//
//  PPTableViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jura on 28/02/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewDataSource.h"

/**
 Table view controller implementation which uses PPTableViewDataSource for managing data 
 */
@interface PPTableViewController : UITableViewController<PPTableViewDataSourceDelegate>

/**
 Object for managing data
 */
@property (nonatomic, strong) PPTableViewDataSource* dataSource;

/**
 Sets up the table view data
 */
- (void)setupTableData;

/**
 Tears down the table view data
 */
- (void)teardownTableData;

@end
