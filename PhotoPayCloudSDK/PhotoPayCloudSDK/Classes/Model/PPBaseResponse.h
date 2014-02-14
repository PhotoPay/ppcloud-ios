//
//  PPBaseResponse.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/23/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPModelObject.h"

@class PPRemoteDocument;

@interface PPBaseResponse : PPModelObject

@property (nonatomic, assign) NSInteger errorCode;

@property (nonatomic, strong) NSString* errorMessage;

@property (nonatomic, strong) NSNumber* totalCount;

@property (nonatomic, strong) NSArray* documentsList;

@property (nonatomic, strong) PPRemoteDocument* document;

@end
