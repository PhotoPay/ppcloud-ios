//
//  PPUserConfirmedValues+Serbia.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/27/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPUserConfirmedValues.h"

@interface PPUserConfirmedValues (Serbia)

- (id)initWithAmount:(NSString*)amount
       accountNumber:(NSString*)accountNumber
     referenceNumber:(NSString*)referenceNumber
      referenceModel:(NSString*)referenceModel;

@end
