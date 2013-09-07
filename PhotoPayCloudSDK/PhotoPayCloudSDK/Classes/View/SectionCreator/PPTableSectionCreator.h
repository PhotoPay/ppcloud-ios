//
//  PPTableSectionCreator.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Abstract class.
 
 Subclasses implement a method which separates an array of items into an array of PPTableSection objects. Resulting
 object can be safely used in PPTableViewDataSource to fill a UITableView layout.
 
 This object enables reuse of often similar methods of populating UITableView with items.
 */
@interface PPTableSectionCreator : NSObject

/**
 Method divides an array of items into sections to be used inside UITableView.
 
 Resulting array must contain PPTableSection objects
 */
 - (NSArray*)createSectionsForItems:(NSArray*)items;

@end
