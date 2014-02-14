//
//  PPUserConfirmedValuesSerbia.h
//  PhotoPayCloudSDK
//
//  Created by Jura on 13/01/14.
//  Copyright (c) 2014 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues.h"

@interface PPUserConfirmedValuesSerbia : PPUserConfirmedValues

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
     referenceNumber:(NSString*)referenceNumber
      referenceModel:(NSString*)referenceModel;

@end
