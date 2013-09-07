//
//  PPHomeViewControllerProtocol.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PPHomeViewControllerProtocol <NSObject>

@required

/**
 Home view controller needs to have a method which opens camera view
 */
- (void)openCamera;

/**
 A method which opens details about a document
 */
- (void)openDocumentDetailsView:(PPDocument*)document;

@end
