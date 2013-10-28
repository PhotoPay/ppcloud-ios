//
//  PPAutoUpdater.h
//  PhotoPay
//
//  Created by Jurica Cerovec on 3/15/13.
//  Copyright (c) 2013 Racuni.hr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPAutoUpdater : NSObject

+ (PPAutoUpdater*)sharedInstance;

- (void)scanUpdatesForAppName:(NSString*)appName
              distributionUrl:(NSString*)distributionUrl;

@end
