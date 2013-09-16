//
//  PPTableLinearSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableLinearSectionCreator.h"
#import "PPTableSection.h"
#import <UIKit/UIKit.h>

@interface PPTableLinearSectionCreator ()

@property (nonatomic, strong) NSMutableArray* sections;

@end

@implementation PPTableLinearSectionCreator

@synthesize sections;

//@interface PPDocumentList ()
//
//@property (nonatomic, strong) NSMutableArray* documentList;
//
//@property (nonatomic, strong) PPUser* user;
//
//@property (nonatomic, strong) PPNetworkManager* networkManager;
//
//@end
//
//@implementation PPDocumentList
//
//@synthesize documentList;
//@synthesize user;
//@synthesize networkManager;
//@synthesize documentStateList;
//
//- (id)initWithUser:(PPUser*)inUser
//    networkManager:(PPNetworkManager*)inNetworkManager {
//    self = [super init];
//    if (self) {
//        user = inUser;
//        networkManager = inNetworkManager;
//        documentStateList = -1;
//    }
//    return self;
//}
//
//- (void)setDocumentStateList:(PPDocumentState)inDocumentStateList {
//    if ([self documentStateList] != inDocumentStateList) {
//        documentStateList = inDocumentStateList;
//        documentList = [[NSMutableArray alloc] init];
//    }
//}
//
//- (void)insertDocument:(PPDocument*)document {
//    BOOL insert = true;
//    int insertIndex = 0;
//    
//    NSLog(@"Document list count before insert %u", [documentList count]);
//    
//    // find a position under which the list would be sorted descending by time
//    // also test for duplicates - if there already exists the same element, don't insert
//    for (int i = 0; i < [documentList count]; i++) {
//        PPDocument *currentDocument = [documentList objectAtIndex:i];
//        
//        // if documents are the same, don't insert at all
//        if ([document isEqualToDocument:currentDocument] &&
//            [document state] == [currentDocument state]) {
//            break;
//        }
//        
//        // Find a document which is older than document which we want to insert
//        if ([[document creationDate] compare:[currentDocument creationDate]] == NSOrderedDescending) {
//            break;
//        } else {
//            insertIndex = i + 1;
//        }
//    }
//    if (insert) {
//        [[self documentList] insertObject:document atIndex:insertIndex];
//        [self.delegate documentListDidUpdate:self.documentList];
//    }
//    
//    NSLog(@"Document list count after insert %u", [documentList count]);
//}
//
//- (void)removeDocument:(PPDocument*)document {
//    NSLog(@"Document list count before remove %u", [documentList count]);
//    for (int i = 0; i < [documentList count]; i++) {
//        PPDocument *currentDocument = [documentList objectAtIndex:i];
//        if ([document isEqualToDocument:currentDocument]) {
//            [documentList removeObjectAtIndex:i];
//            [self.delegate documentListDidUpdate:self.documentList];
//            break;
//        }
//    }
//    
//    NSLog(@"Document list count after remove %u", [documentList count]);
//}
//
//- (void)refreshDocument:(PPDocument*)document {
//    NSLog(@"Document list count before referesh %u", [documentList count]);
//    for (int i = 0; i < [documentList count]; i++) {
//        PPDocument *currentDocument = [documentList objectAtIndex:i];
//        if ([document isEqualToDocument:currentDocument]) {
//            [documentList replaceObjectAtIndex:i withObject:document];
//            [self.delegate documentListDidUpdate:self.documentList];
//            break;
//        }
//    }
//    
//    NSLog(@"Document list count after referesh %u", [documentList count]);
//}
//
//- (void)requestRemoteDocuments {
//    
//}
//
//- (void)swapLocalDocument:(PPLocalDocument*)localDocument
//       withRemoteDocument:(PPRemoteDocument*)remoteDocument {
//}
//
//- (void)refreshLocalDocuments:(PPLocalDocumentUploadQueue*)documentUploadQueue {
//    for (int i = [[self documentList] count] - 1; i >= 0; i--) {
//        PPDocument *document = [[self documentList] objectAtIndex:i];
//        if ([document localDocument] != nil) {
//            [[self documentList] removeObject:document];
//        }
//    }
//    
//    NSLog(@"Document list count before %u", [documentList count]);
//    for (PPLocalDocument* document in [documentUploadQueue elements]) {
//        if ([document state] & [self documentStateList]) {
//            [self insertDocument:document];
//        }
//    }
//    NSLog(@"Document list count after %u", [documentList count]);
//}

- (id)init {
    self = [super init];
    if (self) {
        sections = [[NSMutableArray alloc] init];
        
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:@"Bills"];
        
        [sections addObject:section];
    }
    return self;
}

- (NSIndexPath*)insertItem:(id)item {
    int sectionIndex = [[self sections] count] - 1;
    PPTableSection *section = [[self sections] objectAtIndex:sectionIndex];
    
    [section addItem:item];
    
    int rowIndex = [section itemCount] - 1;
    return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
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

- (NSIndexPath*)reloadItem:(id)item {
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section reloadItem:item];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

@end
