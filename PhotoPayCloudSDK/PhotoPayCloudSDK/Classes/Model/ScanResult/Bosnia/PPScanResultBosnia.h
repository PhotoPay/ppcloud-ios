//
//  PPScanResultAustria.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"

extern NSString* const kPPBosnianAmountKey;
extern NSString* const kPPBosnianAccountNumberKey;
extern NSString* const kPPBosnianRecipientNameKey;
extern NSString* const kPPBosnianReferenceNumberKey;

@interface PPScanResultBosnia : PPScanResult

/** Amount */
- (PPElementCandidateList*)amountCandidateList;

- (PPElementCandidate*)mostProbableAmountCandidate;

/** Account number */
- (PPElementCandidateList*)accountNumberCandidateList;

- (PPElementCandidate*)mostProbableAccountNumberCandidate;

/** Recipient name */
- (PPElementCandidateList*)recipientNameCandidateList;

- (PPElementCandidate*)mostProbableRecipientNameCandidate;

/** Reference number */
- (PPElementCandidateList*)referenceNumberCandidateList;

- (PPElementCandidate*)mostProbableReferenceNumberCandidate;

@end
