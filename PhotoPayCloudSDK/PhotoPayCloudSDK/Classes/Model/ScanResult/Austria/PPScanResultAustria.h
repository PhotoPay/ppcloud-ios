//
//  PPScanResultAustria.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"

extern NSString* const kPPAustrianAmountKey;
extern NSString* const kPPAustrianBankCodeKey;
extern NSString* const kPPAustrianAccountNumberKey;
extern NSString* const kPPAustrianIBANKey;
extern NSString* const kPPAustrianBICKey;
extern NSString* const kPPAustrianBillNumberKey;
extern NSString* const kPPAustrianRecipientNameKey;
extern NSString* const kPPAustrianCustomerNumberKey;

@interface PPScanResultAustria : PPScanResult

/** Amount */
- (PPElementCandidateList*)amountCandidateList;

- (PPElementCandidate*)mostProbableAmountCandidate;

/** Bank code */
- (PPElementCandidateList*)bankCodeCandidateList;

- (PPElementCandidate*)mostProbableBankCodeCandidate;

/** Account number */
- (PPElementCandidateList*)accountNumberCandidateList;

- (PPElementCandidate*)mostProbableAccountNumberCandidate;

/** IBAN */
- (PPElementCandidateList*)ibanCandidateList;

- (PPElementCandidate*)mostProbableIbanCandidate;

/** BIC */
- (PPElementCandidateList*)bicCandidateList;

- (PPElementCandidate*)mostProbableBicCandidate;

/** Bill number */
- (PPElementCandidateList*)billNumberCandidateList;

- (PPElementCandidate*)mostProbableBillNumberCandidate;

/** Recipient name */
- (PPElementCandidateList*)recipientNameCandidateList;

- (PPElementCandidate*)mostProbableRecipientNameCandidate;

/** Customer number */
- (PPElementCandidateList*)customerNumberCandidateList;

- (PPElementCandidate*)mostProbableCustomerNumberCandidate;

@end
