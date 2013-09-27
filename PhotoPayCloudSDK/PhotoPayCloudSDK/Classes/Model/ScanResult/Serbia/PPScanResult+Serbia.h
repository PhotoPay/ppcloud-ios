//
//  PPScanResult+Serbia.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPScanResult.h"

extern NSString* const kPPSerbianAmountKey;
extern NSString* const kPPSerbianAccountNumberKey;
extern NSString* const kPPSerbianReferenceNumberKey;
extern NSString* const kPPSerbianReferenceModelKey;

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

@end
