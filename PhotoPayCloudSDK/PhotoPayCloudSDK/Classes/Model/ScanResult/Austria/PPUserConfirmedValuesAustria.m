//
//  PPUserConfirmedValuesAustria.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValuesAustria.h"
#import "PPScanResultAustria.h"

@implementation PPUserConfirmedValuesAustria

- (id)initWithAmount:(NSString*)amount
            bankCode:(NSString*)bankCode
       accountNumber:(NSString*)accountNumber
                iban:(NSString*)iban
                 bic:(NSString*)bic
          billNumber:(NSString*)billNumber
       recipientName:(NSString*)recipientName
      customerNumber:(NSString*)customerNumber {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.values = [[NSMutableDictionary alloc] init];
    
    [self.values setValue:amount forKey:kPPAustrianAmountKey];
    [self.values setValue:bankCode forKey:kPPAustrianBankCodeKey];
    [self.values setValue:accountNumber forKey:kPPAustrianAccountNumberKey];
    
    [self.values setValue:iban forKey:kPPAustrianIBANKey];
    [self.values setValue:bic forKey:kPPAustrianBICKey];
    
    [self.values setValue:billNumber forKey:kPPAustrianBillNumberKey];
    [self.values setValue:recipientName forKey:kPPAustrianRecipientNameKey];
    [self.values setValue:customerNumber forKey:kPPAustrianCustomerNumberKey];;
    
    return self;
}

@end
