//
//  PPUserConfirmedValuesCroatia.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 26/11/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues.h"

@interface PPUserConfirmedValuesCroatia : PPUserConfirmedValues

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
     referenceNumber:(NSString*)referenceNumber
       recipientName:(NSString*)recipientName
  paymentDescription:(NSString*)paymentDescription
         paymentDate:(NSString*)paymentDate
          billNumber:(NSString*)billNumber;

@end
