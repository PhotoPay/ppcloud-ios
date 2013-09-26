//
//  PPProcessedDocumentView.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/26/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPProcessedDocumentView.h"
#import <PhotoPayCloud/PPScanResult+Serbia.h>

@interface PPProcessedDocumentView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField* firstResponder;

@end

@implementation PPProcessedDocumentView

@synthesize firstResponder;

- (void)setDocument:(PPDocument *)inDocument {
    document = inDocument;
    
    PPScanResult *scanResult = [[inDocument remoteDocument] scanResult];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self addGestureRecognizer:tap];
    
    [self amountTextField].text = @"";
    [self accountTextField].text = @"";
    [self referenceTextField].text = @"";
    
    [self amountTextField].delegate = self;
    [self accountTextField].delegate = self;
    [self referenceTextField].delegate = self;
    
    if (scanResult == nil || [scanResult isEmpty]) {
        return;
    }
    
    [self amountTextField].text = [scanResult mostProbableAmountCandidate].value;
    [self accountTextField].text = [scanResult mostProbableAccountNumberCandidate].value;
    
    NSString* reference = [scanResult mostProbableReferenceNumberCandidate].value;
    NSString* model = [scanResult mostProbableReferenceModelCandidate].value;
    
    if (model != nil && [model length] > 0) {
        [self referenceTextField].text = [NSString stringWithFormat:@"%@ %@", model, reference];
    } else {
        [self referenceTextField].text = reference;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.firstResponder = textField;
    [[self delegate] documentDetailsView:self didMakeViewActive:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.firstResponder = nil;
    [[self delegate] documentDetailsViewDidMakeViewInactive:self];
}

-(void)dismissKeyboard {
    [[self delegate] documentDetailsViewDidMakeViewInactive:self];
    
    [self.firstResponder endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstResponder) {
        [textField endEditing:YES];
        return NO;
    }
    return NO;
}

@end
