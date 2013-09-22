//
//  PPRemoteDocument.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/12/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPDocument.h"

@interface PPRemoteDocument : PPDocument

@property (nonatomic, strong) NSNumber* expectedProcessingTime;

- (void)setThumbnailImage:(UIImage*)thumbnailImage;

- (void)setPreviewImage:(UIImage*)inPreviewImage;

@end
