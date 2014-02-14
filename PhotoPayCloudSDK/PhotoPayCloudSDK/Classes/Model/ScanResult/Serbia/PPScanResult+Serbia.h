//
//  PPScanResult+Serbia.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"
#import "PPScanResultSerbia.h"

@interface PPScanResult (Serbia)

/** Amount */
- (PPElementCandidateList*)amountCandidateList;

- (PPElementCandidate*)mostProbableAmountCandidate;

/** Account number */
- (PPElementCandidateList*)accountNumberCandidateList;

- (PPElementCandidate*)mostProbableAccountNumberCandidate;

/** Reference number */
- (PPElementCandidateList*)referenceNumberCandidateList;

- (PPElementCandidate*)mostProbableReferenceNumberCandidate;

/** Reference model */
- (PPElementCandidateList*)referenceModelCandidateList;

- (PPElementCandidate*)mostProbableReferenceModelCandidate;

/** Recipient name */
- (PPElementCandidateList*)recipientNameCandidateList;

- (PPElementCandidate*)mostProbableRecipientNameCandidate;

@end
