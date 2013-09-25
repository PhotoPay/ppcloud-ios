//
//  PPDocumentTableViewCell+Processing.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/20/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentTableViewCell+Processing.h"
#import "PPApp.h"

@implementation PPDocumentTableViewCell (Processing)

- (void)refreshWithDocumentInProcessing:(PPRemoteDocument*)remoteDocument {
    [self refreshWithDocument:remoteDocument];
    
    [self largeLabel].hidden = YES;
    [self mediumLabel].hidden = YES;
    [self smallLabel].hidden = YES;
    [self progressView].hidden = YES;
    [self midLowerLabel].hidden = NO;
    [self midupperLabel].hidden = NO;
    
    [self midupperLabel].text = _(@"PhotoPayHomeDocumentProcessingLabel");
    int lastDigits = ((int)roundf([remoteDocument expectedProcessingTime].floatValue)) % 100;
    int lastDigit = lastDigits % 10;
    BOOL singular = (lastDigits >= 10 && lastDigits <= 19) || lastDigit > 5 || lastDigit < 2;
    NSString* expectedTimeString = singular ? _(@"PhotoPayHomeDocumentProcessingMinuteSingular") : _(@"PhotoPayHomeDocumentProcessingMinutePlural");
    
    [self midLowerLabel].text = [NSString stringWithFormat:@"%@: %d %@", _(@"PhotoPayHomeDocumentProcessingTimeLabel"), (int)([[remoteDocument expectedProcessingTime] integerValue] + 0.5), expectedTimeString];
}

@end
