//
//  PPScanResult+Serbia.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"

@interface PPScanResult (Serbia)

- (PPElementCandidateList*)amountCandidateList;

- (PPElementCandidate*)mostProbableAmountCandidate;

- (PPElementCandidateList*)accountNumberCandidateList;

- (PPElementCandidate*)mostProbableAccountNumberCandidate;

- (PPElementCandidateList*)referenceNumberCandidateList;

- (PPElementCandidate*)mostProbableReferenceNumberCandidate;

- (PPElementCandidateList*)referenceModelCandidateList;

- (PPElementCandidate*)mostProbableReferenceModelCandidate;

@end
