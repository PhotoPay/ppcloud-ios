//
//  PPDocumentTableViewCell+Processed.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell+Processed.h"

@implementation PPDocumentTableViewCell (Processed)

- (void)refreshWithProcessedDocument:(PPRemoteDocument*)remoteDocument {
    [self refreshWithDocument:remoteDocument];
    
    [self largeLabel].hidden = NO;
    [self mediumLabel].hidden = NO;
    [self smallLabel].hidden = NO;
    [self progressView].hidden = YES;
    [self midLowerLabel].hidden = YES;
    [self midupperLabel].hidden = YES;
    
    [self largeLabel].text = [[remoteDocument scanResult] mostProbableCandidateForKey:@"Amount"].value;
    [self mediumLabel].text = [[remoteDocument scanResult] mostProbableCandidateForKey:@"Account"].value;
    [self smallLabel].text = [[remoteDocument scanResult] mostProbableCandidateForKey:@"Reference"].value;
    
    if ([self largeLabel].text == nil || [self largeLabel].text.length == 0) {
        [self largeLabel].text = _(@"PhotoPayResultsMissingAmount");
    }
    
    if ([self mediumLabel].text == nil || [self mediumLabel].text.length == 0) {
        [self mediumLabel].text = _(@"PhotoPayResultsMissingAccount");
    }
    
    if ([self smallLabel].text == nil || [self largeLabel].text.length == 0) {
        [self smallLabel].text = _(@"PhotoPayResultsMissingReference");
    }
}

@end
