//
//  PPUserConfirmedValuesAustria.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues.h"

@interface PPUserConfirmedValuesBosnia : PPUserConfirmedValues

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
       recipientName:(NSString*)recipientName
     referenceNumber:(NSString*)referenceNumber;

@end
