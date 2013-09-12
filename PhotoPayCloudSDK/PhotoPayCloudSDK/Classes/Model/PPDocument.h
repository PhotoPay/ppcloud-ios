//
//  PPDocument.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPModelObject.h"

/** 
 Defines the states document can be in
 */
typedef NS_ENUM(NSUInteger, PPDocumentState) {
    
    /** 1. States in which the document is stil stored only locally */
    
    /** when document is first created, but upload still hasn't started */
    PPDocumentStateCreated          = (0x1 << 0),
    /** when document upload starts and is still in progress */
    PPDocumentStateUploading        = (0x1 << 1),
    
    /** 2. States in which server has the document, but document processing is still not over */
    
    /** when the server acknowledges that document was successfully uploaded */
    PPDocumentStateReceived         = (0x1 << 2),
    /** when the document is uploaded, but processing still hasn't started */
    PPDocumentStatePending          = (0x1 << 3),
    /** when document processing starts and is still in progress */
    PPDocumentStateProcessing       = (0x1 << 4),
    /** when document processing finishes with error. This means processing will be repeated */
    PPDocumentStateProcessingError  = (0x1 << 5),
    
    /** 3. States in which the processing is over */
    
    /** when document processing finishes with success */
    PPDocumentStateDone             = (0x1 << 6),
    /** 
     when document processing finishes with error several times. Documents in this state will 
     no longer be processed and an error message should be presented to the user 
     */
    PPDocumentStateDoneWithError    = (0x1 << 7),
    
    /** 4. States in which the user has dismissed the processed document */
    
    /** when the user uses the processed results for making the actual payment. */
    PPDocumentStateConfirmed        = (0x1 << 8),
    /** when the user deletes the uploaded document without making the actual payment. */
    PPDocumentStateDeleted          = (0x1 << 9)
};

/**
 Possible file types
 */
typedef NS_ENUM(NSUInteger, PPDocumentType) {
    PPDocumentTypePNG,
    PPDocumentTypeJPG,
    PPDocumentTypeGIF,
    PPDocumentTypeTIFF,
    PPDocumentTypePDF,
    PPDocumentTypeHTML,
    PPDocumentTypeXLS,
    PPDocumentTypeDOC,
    PPDocumentTypeTXT,
    PPDocumentTypeXML,
    PPDocumentTypeJSON
};

@interface PPDocument : PPModelObject {
    NSURL* url_;
}

@property (nonatomic, readonly) NSURL* url;

@property (nonatomic, readonly) PPDocumentState state;

- (id)initWithUrl:(NSURL*)url
    documentState:(PPDocumentState)state;

/**
 Returns object representation of document type enum value
 */
+ (id)objectForDocumentType:(PPDocumentType)documentType;

@end
