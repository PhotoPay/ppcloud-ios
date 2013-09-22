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
    [self mediumLabel].hidden = NO;
    [self smallLabel].hidden = NO;
    [self progressView].hidden = YES;
    
    [self mediumLabel].text = _(@"PhotoPayHomeDocumentProcessingLabel");
    int lastDigits = ((int)roundf([remoteDocument expectedProcessingTime].floatValue * 100.0f)) % 100;
    int lastDigit = lastDigits % 10;
    BOOL singular = (lastDigits >= 10 && lastDigits <= 19) || lastDigit > 5 || lastDigit < 2;
    NSString* expectedTimeString = singular ? _(@"PhotoPayHomeDocumentProcessingMinuteSingular") : _(@"PhotoPayHomeDocumentProcessingMinutePlural");
    
    [self smallLabel].text = [NSString stringWithFormat:@"%@: %.1f %@", _(@"PhotoPayHomeDocumentProcessingTimeLabel"), [[remoteDocument expectedProcessingTime] floatValue], expectedTimeString];
}

@end
