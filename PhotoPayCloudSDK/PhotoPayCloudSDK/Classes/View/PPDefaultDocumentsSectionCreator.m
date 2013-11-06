//
//  PPDefaultDocumentsSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 05/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDefaultDocumentsSectionCreator.h"
#import "PPTableSection.h"
#import "PPDocument.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import <UIKit/UIKit.h>

@interface PPDefaultDocumentsSectionCreator ()

@property (nonatomic, strong) NSMutableArray* sections;

@end

@implementation PPDefaultDocumentsSectionCreator

@synthesize sections;

- (id)init {
    self = [super init];
    if (self) {
        sections = [[NSMutableArray alloc] init];
        
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:nil];
        
        [sections addObject:section];
    }
    return self;
}

- (NSIndexPath*)insertItem:(id)item {
    // we always insert into first section
    
    PPDocument *insertingDocument = nil;
    if ([item isKindOfClass:[PPDocument class]]) {
        insertingDocument = (PPDocument *)item;
    } else {
        return nil;
    }
    
    PPTableSection *section = [[self sections] objectAtIndex:0];
    
    int i = 0;
    for (; i < [section itemCount]; i++) {
        
        NSObject *obj = [[section items] objectAtIndex:i];
        
        BOOL isObjLocal = [obj isKindOfClass:[PPLocalDocument class]];
        BOOL isObjRemote = [obj isKindOfClass:[PPRemoteDocument class]];
        
        BOOL isInsertingLocal = [insertingDocument isKindOfClass:[PPLocalDocument class]];
        BOOL isInsertingRemote = [insertingDocument isKindOfClass:[PPRemoteDocument class]];
        
        PPDocument *document = (PPDocument *)obj;
        
        if (isInsertingLocal) {
            if (isObjRemote) {
                // Remote document is always after local document
                break;
            }
            if (isObjLocal) {
                // Remote documents are sorted by descending creation date
                if ([[document creationDate] compare:[insertingDocument creationDate]] == NSOrderedDescending) {
                    break;
                }
            }
        } else if (isInsertingRemote) {
            if (isObjLocal) {
                // Remote document is always after local document
                continue;
            }
            if (isObjRemote) {
                // Remote documents are sorted by ascending creation date
                if ([[document creationDate] compare:[insertingDocument creationDate]] == NSOrderedAscending) {
                    break;
                }
            }
        }
    }
    
    [section addItem:item atIndex:i];
    
    return [NSIndexPath indexPathForRow:i inSection:0];
}

- (NSIndexPath*)removeItem:(id)item {
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section removeItem:item];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

- (NSIndexPath*)reloadItem:(id)item withItem:(id)other {
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section reloadItem:item withItem:other];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

@end
