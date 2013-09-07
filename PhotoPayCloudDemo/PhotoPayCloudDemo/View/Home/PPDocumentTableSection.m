//
//  PPDocumentTableSection.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableSection.h"

static const int INITIAL_CAPACITY = 20;

@interface PPDocumentTableSection ()

@property (nonatomic, strong) NSMutableArray* mutableItems;

@end

@implementation PPDocumentTableSection

@synthesize sectionId;
@synthesize name;
@synthesize mutableItems;

- (id)initWithSectionId:(NSInteger)inSectionId name:(NSString*)inName {
    self = [super init];
    if (self) {
        sectionId = inSectionId;
        name = inName;
        mutableItems = [[NSMutableArray alloc] initWithCapacity:INITIAL_CAPACITY];
    }
    return self;
}

- (void)addDocument:(PPDocument*)document {
    [[self mutableItems] addObject:document];
}

- (NSArray *)items {
    return [[self mutableItems] copy];
}

- (NSInteger)itemCount {
    return [[self mutableItems] count];
}

@end
