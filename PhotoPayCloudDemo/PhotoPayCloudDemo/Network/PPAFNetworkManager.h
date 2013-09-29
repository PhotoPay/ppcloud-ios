//
//  PPAFNetworkManager.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <PhotoPayCloud/PhotoPayCloud.h>
#import <AFNetworking/AFNetworking.h>

/**
 Concrete implementation of PPNetworkManager which uses AFNetworking for handling network connections
 */
@interface PPAFNetworkManager : PPNetworkManager

/**
 Initializes network managet with a custom httpClient object
 */
- (id)initWithHttpClient:(AFHTTPClient*)httpClient;

/**
 Custom http client object 
 */
@property (nonatomic, strong, readonly) AFHTTPClient* httpClient;

@end
