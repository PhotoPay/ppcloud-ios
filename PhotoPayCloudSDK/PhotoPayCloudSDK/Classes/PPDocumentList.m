//
//  PPDocumentList.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/14/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentList.h"
#import "PPUser.h"
#import "PPNetworkManager.h"
#import "PPLocalDocumentUploadQueue.h"

@interface PPDocumentList ()

@property (nonatomic, strong) NSMutableArray* documentList;

@property (nonatomic, strong) PPUser* user;

@property (nonatomic, strong) PPNetworkManager* networkManager;

@end

@implementation PPDocumentList

@synthesize documentList;
@synthesize user;
@synthesize networkManager;

- (id)initWithUser:(PPUser*)inUser
    networkManager:(PPNetworkManager*)inNetworkManager {
    self = [super init];
    if (self) {
        user = inUser;
        networkManager = inNetworkManager;
    }
    return self;
}

- (void)requestRemoteDocuments {
    
}

- (void)swapLocalDocument:(PPLocalDocument*)localDocument
       withRemoteDocument:(PPRemoteDocument*)remoteDocument {
    
}

- (void)refreshLocalDocuments:(PPLocalDocumentUploadQueue*)documentUploadQueue {
    PPDocument *doc1 = [[PPDocument alloc] init];
    PPDocument *doc2 = [[PPDocument alloc] init];
    PPDocument *doc3 = [[PPDocument alloc] init];
    PPDocument *doc4 = [[PPDocument alloc] init];
    PPDocument *doc5 = [[PPDocument alloc] init];
    
    self.documentList = [[NSMutableArray alloc] initWithObjects:doc1, doc2, doc3, doc4, doc5, nil];
    
    [self.delegate documentListDidUpdate:self.documentList];
}

@end
