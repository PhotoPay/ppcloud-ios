//
//  PPScanResult.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPModelObject.h"

@class PPElementCandidateList;
@class PPElementCandidate;

@interface PPScanResult : PPModelObject

@property (nonatomic, strong) NSString* documentType;

@property (nonatomic, strong) NSDictionary* elements;

- (PPElementCandidateList*)candidateListForKey:(NSString*)key;

- (PPElementCandidate*)mostProbableCandidateForKey:(NSString*)key;

- (BOOL)isEmpty;

@end
