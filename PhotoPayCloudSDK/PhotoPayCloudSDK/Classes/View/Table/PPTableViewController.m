//
//  PPTableViewController.m
//  PhotoPayCloudDemo
//
//  Created by Jura on 28/02/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPTableViewController.h"

@interface PPTableViewController ()

@end

@implementation PPTableViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.dataSource == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Data source must be set in PPTableViewController subclass"
                                     userInfo:nil];
    }
    
    // initialize table data
    [self setupTableData];
    
    // To clear any selection in the table view before it’s displayed
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // flash the scroll view’s scroll indicators
    [[self tableView] flashScrollIndicators];
    
    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self teardownTableData];
}

#pragma mark - Setup / Teardown table data

- (void)setupTableData {
    // set the delegate for data source object
    [self.dataSource setDelegate:self];
}

- (void)teardownTableData {
    // reset the delegate for data source object
    [self.dataSource setDelegate:nil];
}

#pragma mark - Background / Foreground notifications


- (void)setupNotifications {
    // watch for did enter background event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // watch for will enter foreground event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didEnterBackground:(NSNotification *)notification {
    [self teardownTableData];
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self setupTableData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self dataSource] numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self dataSource] tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self dataSource] tableView:tableView titleForHeaderInSection:section];
}

#pragma mark - PPTableViewDataSourceDelegate

- (void)tableViewDataSource:(PPTableViewDataSource *)dataSource didModifyItemsList:(NSArray *)documents {
    // empty implementation, enabled for override
}

/**
 Called when new items are inserted into table view.
 Method passes the exact index paths of the inserted elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
 didInsertItemsAtIndexPaths:(NSArray*)indexPaths {
    [[self tableView] beginUpdates];
    [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
}

/**
 Called when items are deleted from table view.
 Method passes the exact index paths of the deleted elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
 didDeleteItemsAtIndexPaths:(NSArray*)indexPaths {
    [[self tableView] beginUpdates];
    [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];
}

/**
 Called when items are reloaded inside the table view.
 Method passes the exact index paths of the reloaded elements
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
  didReloadItemsAtIndexPath:(NSArray*)indexPaths {
    [[self tableView] beginUpdates];
    [[self tableView] reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
}

/**
 Called when new sections are inserted into table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didInsertSections:(NSIndexSet *)sections {
    [[self tableView] beginUpdates];
    [[self tableView] insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
}

/**
 Called when new sections are deleted into table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didDeleteSections:(NSIndexSet *)sections {
    [[self tableView] beginUpdates];
    [[self tableView] deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];
}

/**
 Called when new sections are reloaded inside the table view.
 Method passes the exact index set of the inserted sections
 */
- (void)tableViewDataSource:(PPTableViewDataSource*)dataSource
          didReloadSections:(NSIndexSet *)sections {
    [[self tableView] beginUpdates];
    [[self tableView] reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
}

@end
