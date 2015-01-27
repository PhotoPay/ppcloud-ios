//
//  PPScanResultCroatia.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 26/11/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPScanResultCroatia.h"

NSString* const kPPCroatianAmountKey = @"Amount";
NSString* const kPPCroatianAccountNumberKey = @"IBAN";
NSString* const kPPCroatianReferenceNumberKey = @"Reference";
NSString* const kPPCroatianRecipientNameKey = @"RecipientName";
NSString* const kPPCroatianPaymentDescriptionKey = @"PaymentDescription";
NSString* const kPPCroatianPaymentDateKey = @"PaymentDate";
NSString* const kPPCroatianBillNumberKey = @"BillNumber";

@implementation PPScanResultCroatia

- (PPElementCandidateList*)amountCandidateList {
    return [self candidateListForKey:kPPCroatianAmountKey];
}

- (PPElementCandidate*)mostProbableAmountCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianAmountKey];
}

- (PPElementCandidateList*)accountNumberCandidateList {
    return [self candidateListForKey:kPPCroatianAccountNumberKey];
}

- (PPElementCandidate*)mostProbableAccountNumberCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianAccountNumberKey];
}

- (PPElementCandidateList*)referenceNumberCandidateList {
    return [self candidateListForKey:kPPCroatianReferenceNumberKey];
}

- (PPElementCandidate*)mostProbableReferenceNumberCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianReferenceNumberKey];
}

- (PPElementCandidateList*)recipientNameCandidateList {
    return [self candidateListForKey:kPPCroatianRecipientNameKey];
}

- (PPElementCandidate*)mostProbableRecipientNameCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianRecipientNameKey];
}

- (PPElementCandidateList*)paymentDescriptionCandidateList {
    return [self candidateListForKey:kPPCroatianPaymentDescriptionKey];
}

- (PPElementCandidate*)mostProbablePaymentDescriptionCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianPaymentDescriptionKey];
}

- (PPElementCandidateList*)paymentDateCandidateList {
    return [self candidateListForKey:kPPCroatianPaymentDateKey];
}

- (PPElementCandidate*)mostProbablePaymentDateCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianPaymentDateKey];
}

- (PPElementCandidateList*)billNumberCandidateList {
    return [self candidateListForKey:kPPCroatianBillNumberKey];
}

- (PPElementCandidate*)mostProbableBillNumberCandidate {
    return [self mostProbableCandidateForKey:kPPCroatianBillNumberKey];
}

@end
