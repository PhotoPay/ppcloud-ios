//
//  PPUserConfirmedValuesSerbia.m
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValuesSerbia.h"
#import "PPScanResultSerbia.h"

@implementation PPUserConfirmedValuesSerbia

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
     referenceNumber:(NSString*)referenceNumber
      referenceModel:(NSString*)referenceModel {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.values = [[NSMutableDictionary alloc] init];
    [self.values setValue:amount forKey:kPPSerbianAmountKey];
    [self.values setValue:accountNumber forKey:kPPSerbianAccountNumberKey];
    [self.values setValue:referenceNumber forKey:kPPSerbianReferenceNumberKey];
    [self.values setValue:referenceModel forKey:kPPSerbianReferenceModelKey];
    
    return self;
}

@end
