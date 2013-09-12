//
//  PPAFNetworkManager.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <PhotoPayCloud/PhotoPayCloud.h>
#import <AFNetworking/AFNetworking.h>

@interface PPAFNetworkManager : PPNetworkManager

- (id)initWithHttpClient:(AFHTTPClient*)httpClient;

@property (nonatomic, strong, readonly) AFHTTPClient* httpClient;

@end
