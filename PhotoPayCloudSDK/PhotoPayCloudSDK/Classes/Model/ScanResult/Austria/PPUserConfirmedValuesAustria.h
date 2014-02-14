//
//  PPUserConfirmedValuesAustria.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues.h"

@interface PPUserConfirmedValuesAustria : PPUserConfirmedValues

- (id)initWithAmount:(NSString*)amount
            bankCode:(NSString*)bankCode
       accountNumber:(NSString*)accountNumber
                iban:(NSString*)iban
                 bic:(NSString*)bic
          billNumber:(NSString*)billNumber
       recipientName:(NSString*)recipientName
      customerNumber:(NSString*)customerNumber;

@end
