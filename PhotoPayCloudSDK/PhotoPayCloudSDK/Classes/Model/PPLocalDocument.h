//
//  PPLocalDocument.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPDocument.h"

@class PPDocumentManager;

/**
 Encapsulates a local PhotoPay cloud document object 
 */
@interface PPLocalDocument : PPDocument {
    NSData *bytes_;
}

@property (nonatomic, strong, readonly) NSData *bytes;

@property (nonatomic, readonly) PPDocumentType type;

- (id)initWithBytes:(NSData*)inBytes
               type:(PPDocumentType)inType;

- (void)saveUsingDocumentManager:(PPDocumentManager*)documentManager
                         success:(void(^)(NSURL* documentUrl))success
                         failure:(void(^)(NSError* error))failure;

+ (NSString*)extensionForDocumentType:(PPDocumentType)type;

+ (NSString*)generateUniqueFilenameForType:(PPDocumentType)type;

@end
