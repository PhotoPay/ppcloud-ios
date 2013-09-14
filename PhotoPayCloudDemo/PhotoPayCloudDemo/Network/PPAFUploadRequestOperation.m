//
//  PPAFUploadRequestOperation.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPAFUploadRequestOperation.h"

@implementation PPAFUploadRequestOperation

@synthesize delegate;
@synthesize progress;

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (self) {
        delegate = nil;
        progress = @(0.0);
    }
    return self;
}

- (void)cancel {
    [super cancel];
}

@end
