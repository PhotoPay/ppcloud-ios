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
 
 You have three options here.
 
 1. The simplest and probably the most is to use UIImagePickerController for taking photos.
 2. Second option is to subclass PPBaseCameraViewController class and provide your own CameraViewController. AVCaptureSession management here is done by PPCameraManager object.
 3. Implement everything by yourself, including AVCaptureSession management and camera UI
 */
- (void)openCamera;

/**
 A method which opens details about a document
 */
- (void)openDocumentDetailsView:(PPDocument*)document;

@end
