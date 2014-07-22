//
//  PPUserConfirmedValuesAustria.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValuesBosnia.h"
#import "PPScanResultBosnia.h"

@implementation PPUserConfirmedValuesBosnia

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
       recipientName:(NSString*)recipientName
     referenceNumber:(NSString*)referenceNumber {

    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.values = [[NSMutableDictionary alloc] init];
    
    [self.values setValue:amount forKey:kPPBosnianAmountKey];
    [self.values setValue:accountNumber forKey:kPPBosnianAccountNumberKey];
    [self.values setValue:recipientName forKey:kPPBosnianRecipientNameKey];
    [self.values setValue:referenceNumber forKey:kPPBosnianReferenceNumberKey];
    
    return self;
}

@end
