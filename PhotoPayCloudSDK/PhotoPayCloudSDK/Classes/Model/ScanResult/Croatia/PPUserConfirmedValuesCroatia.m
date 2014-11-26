//
//  PPUserConfirmedValuesCroatia.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 26/11/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValuesCroatia.h"
#import "PPScanResultCroatia.h"

@implementation PPUserConfirmedValuesCroatia

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
     referenceNumber:(NSString*)referenceNumber
      referenceModel:(NSString*)referenceModel
       recipientName:(NSString*)recipientName
  paymentDescription:(NSString*)paymentDescription {

    self = [super init];
    if (!self) {
        return nil;
    }

    self.values = [[NSMutableDictionary alloc] init];
    [self.values setValue:amount forKey:kPPCroatianAmountKey];
    [self.values setValue:accountNumber forKey:kPPCroatianAccountNumberKey];
    [self.values setValue:referenceNumber forKey:kPPCroatianReferenceNumberKey];
    [self.values setValue:referenceModel forKey:kPPCroatianReferenceModelKey];
    [self.values setValue:recipientName forKey:kPPCroatianRecipientNameKey];
    [self.values setValue:paymentDescription forKey:kPPCroatianPaymentDescriptionKey];

    return self;
}

@end
