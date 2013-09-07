//
//  PPTableLinearSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableLinearSectionCreator.h"
#import "PPTableSection.h"

@implementation PPTableLinearSectionCreator

- (NSArray*)createSectionsForItems:(NSArray *)items {
    
    // simple table section building strategy, just push all documents into one section
    PPTableSection *section1 = [[PPTableSection alloc] initWithSectionId:0 name:nil];
    
    for (id item in items) {
        [section1 addItem:item];
    }
    
    return [[NSArray alloc] initWithObjects:section1, nil];
}

@end
