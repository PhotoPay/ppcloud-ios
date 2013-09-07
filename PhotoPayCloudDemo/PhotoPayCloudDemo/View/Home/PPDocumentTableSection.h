//
//  PPDocumentTableSection.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Helper class to encapsulate all Document object which go into the same section of the table view
 */
@interface PPDocumentTableSection : NSObject

/**
 Unique id (e.g index in the table sections) of this section
 */
@property (nonatomic) NSInteger sectionId;

/**
 Readonly and immutable because it doesn't make sense to update tabe view section without updating the actual
 Document list.
 
 To update table view, set the Documents property of the table view source and reload view. Thank you.
 */
@property (nonatomic, strong, readonly) NSArray* items;

/**
 Name, as seen in the table view
 */
@property (nonatomic, strong) NSString* name;

/**
 Designated initializer
 */
- (id)initWithSectionId:(NSInteger)sectionId name:(NSString*)name;

/**
 Adds the document to the section.
 */
- (void)addDocument:(PPDocument*)document;

/**
 Helper method for obtaining section item count
 
 Faster than [[self items] count];
 */
- (NSInteger)itemCount;

@end
