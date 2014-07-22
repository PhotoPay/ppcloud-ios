//
//  PPScanResultAustria.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResultBosnia.h"

NSString* const kPPBosnianAmountKey = @"Amount";
NSString* const kPPBosnianAccountNumberKey = @"Account";
NSString* const kPPBosnianRecipientNameKey = @"RecipientName";
NSString* const kPPBosnianReferenceNumberKey = @"Reference";

@implementation PPScanResultBosnia

- (PPElementCandidateList*)amountCandidateList {
    return [self candidateListForKey:kPPBosnianAmountKey];
}

- (PPElementCandidate*)mostProbableAmountCandidate {
    return [self mostProbableCandidateForKey:kPPBosnianAmountKey];
}

/** Account number */
- (PPElementCandidateList*)accountNumberCandidateList {
    return [self candidateListForKey:kPPBosnianAccountNumberKey];
}

- (PPElementCandidate*)mostProbableAccountNumberCandidate {
    return [self mostProbableCandidateForKey:kPPBosnianAccountNumberKey];
}

/** Recipient name */
- (PPElementCandidateList*)recipientNameCandidateList {
    return [self candidateListForKey:kPPBosnianRecipientNameKey];
}

- (PPElementCandidate*)mostProbableRecipientNameCandidate {
    return [self mostProbableCandidateForKey:kPPBosnianRecipientNameKey];
}

/** Reference number */
- (PPElementCandidateList*)referenceNumberCandidateList {
    return [self candidateListForKey:kPPBosnianReferenceNumberKey];
}

- (PPElementCandidate*)mostProbableReferenceNumberCandidate {
    return [self mostProbableCandidateForKey:kPPBosnianReferenceNumberKey];
}

@end
