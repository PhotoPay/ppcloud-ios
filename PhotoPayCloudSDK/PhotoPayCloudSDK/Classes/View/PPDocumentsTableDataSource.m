//
//  PPDocumentsTableDataSource.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/16/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsTableDataSource.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import "PPLocalDocumentUploadQueue.h"

@interface PPDocumentsTableDataSource ()

@property (nonatomic, assign) PPDocumentState documentStates;

@end

@implementation PPDocumentsTableDataSource

- (void)swapLocalDocument:(PPLocalDocument *)localDocument
       withRemoteDocument:(PPRemoteDocument *)remoteDocument {
    NSLog(@"Swapping");
}

@end
