//
//  PPTableSection.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Helper class to encapsulate all objects which go into the same section of the table view
 
 PPTableSection object should be completely managed by PPTableViewDataSource and PPTableViewSectionManager objects, not created manually.
 */
@interface PPTableSection : NSObject

/**
 Unique id (e.g index in the table sections) of this section
 */
@property (nonatomic) NSInteger sectionId;

/**
 Readonly and immutable because updating views should be done only by changing appropriate model objects.
 
 Try to avoid getting your view and model into inconsistent state. Update PPTableViewDataSource object with modified model objects and use PPTableViewSectionManager to recreate sections automatically.
 */
@property (nonatomic, strong, readonly) NSArray* items;

/**
 Name of the section, as seen in the table view
 */
@property (nonatomic, strong) NSString* name;

/**
 Designated initializer
 */
- (id)initWithSectionId:(NSInteger)sectionId name:(NSString*)name;

/**
 Adds the item to the section.
 */
- (void)addItem:(id)item;

/**
 Removes the item from the section. Section is traversed and checked if there is an existing element which responds YES to [element isEqual:item]
 If there exists one, it's removed from the list, and it's index is returned.
 
 If there is none, NSNotFound is returned.
 
 Only one element can be removed, if there are duplicates, they will remain in the section.
 */
- (NSUInteger)removeItem:(id)item;

/**
 Reloads the item int the section. Section is traversed and checked if there is an existing element which responds YES to [element isEqual:item]
 If there exists one, it's replaced with the given item, and it's index is returned.
 
 If there is none, NSUInteger is returned.
 
 Only one element can be reloaded, if there are duplicates, they will remain unchanged in the section.
 */
- (NSUInteger)reloadItem:(id)item;

/**
 Helper method for obtaining section item count
 
 Faster than [[self items] count];
 */
- (NSInteger)itemCount;

@end
