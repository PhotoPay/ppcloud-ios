//
//  PPDocumentList.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/14/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPDocument.h";

@protocol PPDocumentListDelegate;
@class PPNetworkManager;
@class PPUser;
@class PPLocalDocumentUploadQueue;
@class PPLocalDocument;
@class PPRemoteDocument;

@interface PPDocumentList : NSObject

@property (nonatomic, weak) id<PPDocumentListDelegate> delegate;

- (id)initWithUser:(PPUser*)user
    networkManager:(PPNetworkManager*)networkManager;

@property (nonatomic, assign) PPDocumentState documentStateList;

- (void)requestRemoteDocuments;

- (void)swapLocalDocument:(PPLocalDocument*)localDocument
       withRemoteDocument:(PPRemoteDocument*)remoteDocument;

- (void)refreshLocalDocuments:(PPLocalDocumentUploadQueue*)documentUploadQueue;

@end

@protocol PPDocumentListDelegate <NSObject>

- (void)documentListDidUpdate:(NSArray*)documents;

@end
