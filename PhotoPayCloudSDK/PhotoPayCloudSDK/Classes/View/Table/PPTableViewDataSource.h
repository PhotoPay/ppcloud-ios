//
//  PPTableViewDataSource.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PPTableViewDataSourceDelegate;
@class PPTableSectionCreator;

/**
 Data source for UITableView with list of items which need to be presented in a table view
 */
@interface PPTableViewDataSource : NSObject <UITableViewDataSource>

/**
 Defines a section creator which divides items into sections for display inside UITableView
 
 This object must be a subclass of PPTableSectionCreator
 */
@property (nonatomic, strong) PPTableSectionCreator* sectionCreator;

/**
 Delegate object which gets notified on inserted/deleted/reloaded items in the table
 */
@property (nonatomic, weak) id<PPTableViewDataSourceDelegate> delegate;

/** 
 A list of all items in the data source
 
 Accessing this property is O(number_of_items), so use it sparingly
 */
- (NSArray*)items;

/**
 Initializes the data source with given section creator
 */
- (id)initWithSectionCreator:(PPTableSectionCreator*)inSectionCreator;

/**
 Retrieves an item with indexpath from the data source
 */
- (id)itemForIndexPath:(NSIndexPath*)indexPath;

/**
 Inserts the items into table view. Depending on the section creators, 
 inserted items will appear in different sections
 */
- (void)insertItems:(NSArray*)items;

/**
 Removes the items from the table view. Depending on the section creators,
 removed items will dissapear from different sections
 */
- (void)removeItems:(NSArray*)items;

/**
 Reloads the items in the table view. Section creator decides how the reloading should be done.
 */
- (void)reloadItems:(NSArray*)items
          withItems:(NSArray*)other;

@end

/**
 Delegate protocol which table view which displays items has to implement
 
 It contains callback methods on which the table view should update the UI
 */
@protocol PPTableViewDataSourceDelegate <NSObject>

@required

/**
 Called when new items are inserted into table view. 
 Method passes the exact index paths of the inserted elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
 didInsertItemsAtIndexPaths:(NSArray*)indexPaths;

/**
 Called when items are deleted from table view.
 Method passes the exact index paths of the deleted elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
 didDeleteItemsAtIndexPaths:(NSArray*)indexPaths;

/**
 Called when items are reloaded inside the table view.
 Method passes the exact index paths of the reloaded elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
  didReloadItemsAtIndexPath:(NSArray*)indexPaths;

/**
 Called when new sections are inserted into table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didInsertSections:(NSIndexSet *)sections;

/**
 Called when new sections are deleted into table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didDeleteSections:(NSIndexSet *)sections;

/**
 Called when new sections are reloaded inside the table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didReloadSections:(NSIndexSet *)sections;

@optional

/**
 Called when there was update to data source items
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
         didModifyItemsList:(NSArray*)items;

@end
