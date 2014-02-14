//
//  PPScanResultAustria.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResultAustria.h"

NSString* const kPPAustrianAmountKey = @"Amount";
NSString* const kPPAustrianBankCodeKey = @"BankCode";
NSString* const kPPAustrianAccountNumberKey = @"Account";
NSString* const kPPAustrianIBANKey = @"IBAN";
NSString* const kPPAustrianBICKey = @"BIC";
NSString* const kPPAustrianBillNumberKey = @"BillNumber";
NSString* const kPPAustrianRecipientNameKey = @"RecipientName";
NSString* const kPPAustrianCustomerNumberKey = @"CustomerNumber";

@implementation PPScanResultAustria

- (PPElementCandidateList*)amountCandidateList {
    return [self candidateListForKey:kPPAustrianAmountKey];
}

- (PPElementCandidate*)mostProbableAmountCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianAmountKey];
}

/** Bank code */
- (PPElementCandidateList*)bankCodeCandidateList {
    return [self candidateListForKey:kPPAustrianBankCodeKey];
}

- (PPElementCandidate*)mostProbableBankCodeCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianBankCodeKey];
}

/** Account number */
- (PPElementCandidateList*)accountNumberCandidateList {
    return [self candidateListForKey:kPPAustrianAccountNumberKey];
}

- (PPElementCandidate*)mostProbableAccountNumberCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianAccountNumberKey];
}

/** IBAN */
- (PPElementCandidateList*)ibanCandidateList {
    return [self candidateListForKey:kPPAustrianIBANKey];
}

- (PPElementCandidate*)mostProbableIbanCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianIBANKey];
}

/** BIC */
- (PPElementCandidateList*)bicCandidateList {
    return [self candidateListForKey:kPPAustrianBICKey];
}

- (PPElementCandidate*)mostProbableBicCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianBICKey];
}

/** Bill number */
- (PPElementCandidateList*)billNumberCandidateList {
    return [self candidateListForKey:kPPAustrianBillNumberKey];
}

- (PPElementCandidate*)mostProbableBillNumberCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianBillNumberKey];
}

/** Recipient name */
- (PPElementCandidateList*)recipientNameCandidateList {
    return [self candidateListForKey:kPPAustrianRecipientNameKey];
}

- (PPElementCandidate*)mostProbableRecipientNameCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianRecipientNameKey];
}

/** Customer number */
- (PPElementCandidateList*)customerNumberCandidateList {
    return [self candidateListForKey:kPPAustrianCustomerNumberKey];
}

- (PPElementCandidate*)mostProbableCustomerNumberCandidate {
    return [self mostProbableCandidateForKey:kPPAustrianCustomerNumberKey];
}

@end
