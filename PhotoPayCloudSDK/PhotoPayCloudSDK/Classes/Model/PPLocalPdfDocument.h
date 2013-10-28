//
//  PPLocalPdfDocument.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 27/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPLocalDocument.h"

@interface PPLocalPdfDocument : PPLocalDocument

- (id)initWithLocalUrl:(NSURL*)localUrl
        processingType:(PPDocumentProcessingType)inProcessingType;

@end
