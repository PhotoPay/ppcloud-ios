//
//  PPTableSectionCreator.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPTableSection;

/**
 Abstract class.
 
 Subclasses implement a method which separates an array of items into an array of PPTableSection objects. Resulting
 object can be safely used in PPTableViewDataSource to fill a UITableView layout.
 
 This object enables reuse of often similar methods of populating UITableView with items.
 */
@interface PPTableSectionCreator : NSObject <NSCopying>

@property (nonatomic, strong) NSMutableArray* sections;

- (NSUInteger)sectionCount;

- (PPTableSection*)findSectionWithId:(NSInteger)sectionId;

- (NSIndexPath*)indexPathForObject:(id)item;

- (NSUInteger)indexForSection:(id)item;

- (NSIndexPath*)insertItem:(id)item;

- (NSIndexPath*)removeItem:(id)item;

- (NSIndexPath*)reloadItem:(id)item withItem:(id)other;

@end
