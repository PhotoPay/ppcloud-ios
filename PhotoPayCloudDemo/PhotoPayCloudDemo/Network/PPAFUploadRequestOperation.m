//
//  PPAFUploadRequestOperation.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPAFUploadRequestOperation.h"

@implementation PPAFUploadRequestOperation

@synthesize uploadParameters;
@synthesize delegate;
@synthesize progress;

- (id)initWithRequest:(NSURLRequest *)urlRequest
     uploadParameters:(PPUploadParameters*)inUploadParameters {
    self = [super initWithRequest:urlRequest];
    if (self) {
        uploadParameters = inUploadParameters;
        delegate = nil;
        progress = @(0.0);
    }
    return self;
}

@end
