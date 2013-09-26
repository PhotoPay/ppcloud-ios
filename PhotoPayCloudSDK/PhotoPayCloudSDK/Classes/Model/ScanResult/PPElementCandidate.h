//
//  PPElementCandidate.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPModelObject.h"

@class PPElementPosition;

@interface PPElementCandidate : PPModelObject

@property (nonatomic, strong) NSNumber* confidence;

@property (nonatomic, strong) PPElementPosition* position;

@property (nonatomic, strong) NSString* value;

@end
