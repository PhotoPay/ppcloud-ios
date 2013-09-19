//
//  PPDocumentViewFactory.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PhotoPayCloud/PhotoPayCloud.h>
#import "PPDocumentDetailsView.h"

@interface PPDocumentViewFactory : NSObject

- (id)initWithDocument:(PPDocument*)inDocument;

- (PPDocumentDetailsView*)documentViewForDocumentState:(PPDocumentState)state;

@end
