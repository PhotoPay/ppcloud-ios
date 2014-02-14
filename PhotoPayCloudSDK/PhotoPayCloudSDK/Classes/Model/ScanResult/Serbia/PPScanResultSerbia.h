//
//  PPScanResultSerbia.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"

extern NSString* const kPPSerbianAmountKey;
extern NSString* const kPPSerbianAccountNumberKey;
extern NSString* const kPPSerbianReferenceNumberKey;
extern NSString* const kPPSerbianReferenceModelKey;
extern NSString* const kPPSerbianRecipientNameKey;

@interface PPScanResultSerbia : PPScanResult

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
