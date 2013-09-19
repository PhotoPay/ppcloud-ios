//
//  PPDocument.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PPModelObject.h"

@protocol PPDocumentStateChangedDelegate;
@class PPLocalDocument;
@class PPRemoteDocument;

/** 
 Defines the states document can be in
 */
typedef NS_ENUM(NSUInteger, PPDocumentState) {
    
    /** 1. States of LocalDocument objects */
    
    /** when document is first created in memory */
    PPDocumentStateCreated          = (0x1 << 0),
    /** before the upload starts, document first has to be stored on persistent storage (usually filesystem) */
    PPDocumentStateStored           = (0x1 << 1),
    /** when document upload starts and is still in progress */
    PPDocumentStateUploading        = (0x1 << 2),
    /** when document upload started but failed */
    PPDocumentStateUploadFailed     = (0x1 << 3),
    
    /** Document is local if it's in one of these three states */
    PPDocumentStateLocal            = PPDocumentStateCreated | PPDocumentStateStored | PPDocumentStateUploading | PPDocumentStateUploadFailed,
    
    /** 2. States of RemoteDocument objects */
    
    /** when the server acknowledges that document was successfully uploaded */
    PPDocumentStateReceived         = (0x1 << 4),
    /** when the document is uploaded, but processing still hasn't started */
    PPDocumentStatePending          = (0x1 << 5),
    /** when document processing starts and is still in progress */
    PPDocumentStateProcessing       = (0x1 << 6),
    /** when document processing finishes with error. This means processing will be repeated */
    PPDocumentStateProcessingError  = (0x1 << 7),
    /** when document processing finishes with success */
    PPDocumentStateProcessed        = (0x1 << 8),
    /**  when document processing finishes with error several times. Documents in this state will
     no longer be processed and an error message should be presented to the user */
    PPDocumentStateProcessedWithError    = (0x1 << 9),
    /** when the user uses the processed results for making the actual payment. */
    PPDocumentStatePaid             = (0x1 << 10),
    /** when the user deletes the uploaded document without making the actual payment. */
    PPDocumentStateDeleted          = (0x1 << 11),
    
    /** Document is local if it's in one of these three states */
    PPDocumentStateRemoteUnconfirmed  = PPDocumentStateReceived | PPDocumentStatePending | PPDocumentStateProcessing | PPDocumentStateProcessingError | PPDocumentStateProcessed | PPDocumentStateProcessedWithError,
    
//    /** Shortcut to unknown state *
    PPDocumentStateUnknown          = (0x1 << 30),
};

/**
 Possible file types
 */
typedef NS_ENUM(NSUInteger, PPDocumentType) {
    PPDocumentTypePNG, // png image
    PPDocumentTypeJPG, // jpeg image
    PPDocumentTypeGIF, // gif image
    PPDocumentTypeTIFF, // tiff image
    PPDocumentTypePDF, // pdf document
    PPDocumentTypeHTML, // html document
    PPDocumentTypeXLS, // excel document
    PPDocumentTypeDOC, // word document
    PPDocumentTypeTXT, // textual document
    PPDocumentTypeXML, // xml document
    PPDocumentTypeJSON // json document
};

/**
 Different documents require different processing methods. Application defines which processing type
 is needed for a document. Currently available methods will be listed in this enum.
 */
typedef NS_ENUM(NSUInteger, PPDocumentProcessingType) {
    // requires processing for photos of Serbian invoices
    PPDocumentProcessingTypeSerbianPhotoInvoice,
    // requires processing for serbian PDF invocies
    PPDocumentProcessingTypeSerbianPDFInvoice,
    // requires processing for photos of Austrian invoices
    PPDocumentProcessingTypeAustrianPhotoInvoice,
    // requires processing for Austrian PDF invoices
    PPDocumentProcessingTypeAustrianPDFInvoice
};

/**
 Abstract document class
 */
@interface PPDocument : PPModelObject <NSCoding> {
    NSURL* url_;
}

/** 
 URL pointing to the location of the document.
 Can be url both local or remote 
 */
@property (nonatomic, strong) NSURL* url;

/**
 State in which is the document.
 
 @see PPDocumentState enum
 */
@property (nonatomic, assign) PPDocumentState state;

/**
 Type of the document
 
 @see PPDocumentType enum
 */
@property (nonatomic, assign, readonly) PPDocumentType documentType;

/**
 Type of processing this document requires
 
 @see PPDocumentProcessingType
 */
@property (nonatomic, assign, readonly) PPDocumentProcessingType processingType;

/**
 Exact date of the creation of the document
 */
@property (nonatomic, strong, readonly) NSDate* creationDate;

/** Delegate for state changed notifications */
@property (nonatomic, weak) id<PPDocumentStateChangedDelegate> delegate;

/**
 Designated initializer
 */
- (id)initWithUrl:(NSURL*)url
    documentState:(PPDocumentState)state
     documentType:(PPDocumentType)documentType
   processingType:(PPDocumentProcessingType)processingType;

/**
 Returns a mime type of a this document
 
 Mime type is determined by documentType enum
 */
- (NSString*)mimeType;

/**
 Generates and chaches thumbnail image for this document
 */
- (void)thumbnailImageWithSuccess:(void (^)(UIImage* thumbnailImage))success
                          failure:(void (^)(void))failure;

/**
 Generates and chaches preview image for this document
 */
- (void)previewImageWithSuccess:(void (^)(UIImage* previewImage))success
                        failure:(void (^)(void))failure;

/**
 Safely checks if this document is in fact a local document. If not, returns nil, else returns caster reference
 */
- (PPLocalDocument*)localDocument;

/**
 Safely checks if this document is in fact a remote document. If not, returns nil, else returns caster reference
 */
- (PPRemoteDocument*)remoteDocument;

/**
 Returns object representation of document type enum value
 */
+ (id)objectForDocumentType:(PPDocumentType)documentType;

/**
 Returns object representation for the PPDocumentProcessingType enum
 */
+ (id)objectForDocumentProcessingType:(PPDocumentProcessingType)type;

/**
 Returns object representation for the PPDocumentState enum
 */
+ (id)objectForDocumentState:(PPDocumentState)documentState;

@end

/**
 Protocol for delegates which get notified on document change state
 */
@protocol PPDocumentStateChangedDelegate <NSObject>

@required
/**
 Method called when document's state is changed
 
 Guaranteed to be called on the main thread
 */
- (void)documentDidChangeState:(PPDocument*)document;

@end
