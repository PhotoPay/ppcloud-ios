//
//  PPScanResultCroatia.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 26/11/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"

extern NSString* const kPPCroatianAmountKey;
extern NSString* const kPPCroatianAccountNumberKey;
extern NSString* const kPPCroatianReferenceNumberKey;
extern NSString* const kPPCroatianReferenceModelKey;
extern NSString* const kPPCroatianRecipientNameKey;
extern NSString* const kPPCroatianPaymentDescriptionKey;

@interface PPScanResultCroatia : PPScanResult

/** Amount */
- (PPElementCandidateList*)amountCandidateList;

- (PPElementCandidate*)mostProbableAmountCandidate;

/** Account number */
- (PPElementCandidateList*)accountNumberCandidateList;

- (PPElementCandidate*)mostProbableAccountNumberCandidate;

/** Reference number */
- (PPElementCandidateList*)referenceNumberCandidateList;

- (PPElementCandidate*)mostProbableReferenceNumberCandidate;

/** ReferenceModel */
- (PPElementCandidateList*)referenceModelCandidateList;

- (PPElementCandidate*)mostProbableReferenceModelCandidate;

/** Recipient name */
- (PPElementCandidateList*)recipientNameCandidateList;

- (PPElementCandidate*)mostProbableRecipientNameCandidate;

/** PaymentDescription */
- (PPElementCandidateList*)paymentDescriptionCandidateList;

- (PPElementCandidate*)mostProbablePaymentDescriptionCandidate;

@end
