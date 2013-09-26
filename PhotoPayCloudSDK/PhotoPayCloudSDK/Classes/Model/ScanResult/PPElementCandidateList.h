//
//  PPElementCandidateList.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPModelObject.h"

@interface PPElementCandidateList : PPModelObject

@property (nonatomic, strong) NSArray* candidates;

- (NSUInteger)count;

@end
