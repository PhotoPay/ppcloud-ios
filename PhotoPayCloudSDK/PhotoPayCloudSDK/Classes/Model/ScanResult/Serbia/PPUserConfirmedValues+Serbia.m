//
//  PPUserConfirmedValues+Serbia.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/27/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues+Serbia.h"
#import "PPScanResultSerbia.h"

@implementation PPUserConfirmedValues (Serbia)

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
