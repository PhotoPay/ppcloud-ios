//
//  PPScanResult+Serbia.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPScanResult+Serbia.h"

@implementation PPScanResult (Serbia)

- (PPElementCandidateList*)amountCandidateList {
    return [self candidateListForKey:kPPSerbianAmountKey];
}

- (PPElementCandidate*)mostProbableAmountCandidate {
    return [self mostProbableCandidateForKey:kPPSerbianAmountKey];
}

- (PPElementCandidateList*)accountNumberCandidateList {
    return [self candidateListForKey:kPPSerbianAccountNumberKey];
}

- (PPElementCandidate*)mostProbableAccountNumberCandidate {
    return [self mostProbableCandidateForKey:kPPSerbianAccountNumberKey];
}

- (PPElementCandidateList*)referenceNumberCandidateList {
    return [self candidateListForKey:kPPSerbianReferenceNumberKey];
}

- (PPElementCandidate*)mostProbableReferenceNumberCandidate {
    return [self mostProbableCandidateForKey:kPPSerbianReferenceNumberKey];
}

- (PPElementCandidateList*)referenceModelCandidateList {
    return [self candidateListForKey:kPPSerbianReferenceModelKey];
}

- (PPElementCandidate*)mostProbableReferenceModelCandidate {
    return [self mostProbableCandidateForKey:kPPSerbianReferenceModelKey];
}

- (PPElementCandidateList*)recipientNameCandidateList {
    return [self candidateListForKey:kPPSerbianRecipientNameKey];
}

- (PPElementCandidate*)mostProbableRecipientNameCandidate {
    return [self mostProbableCandidateForKey:kPPSerbianRecipientNameKey];
}

@end
