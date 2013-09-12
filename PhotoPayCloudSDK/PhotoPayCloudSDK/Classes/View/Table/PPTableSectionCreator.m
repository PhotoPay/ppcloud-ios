//
//  PPTableSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableSectionCreator.h"

@implementation PPTableSectionCreator

- (NSArray*)createSectionsForItems:(id)items {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil];
}

@end
