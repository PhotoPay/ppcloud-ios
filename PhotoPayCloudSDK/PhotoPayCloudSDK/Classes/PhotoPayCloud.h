//
//  PhotoPayCloud.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#ifndef _PHOTOPAY_CLOUD_
#define _PHOTOPAY_CLOUD_

#import <Foundation/Foundation.h>

/** model headers */
#import "PPModelObject.h"
#import "PPBaseResponse.h"
#import "PPDocument.h"
#import "PPLocalDocument.h"
#import "PPLocalImageDocument.h"
#import "PPLocalPdfDocument.h"
#import "PPRemoteDocument.h"
#import "PPUser.h"
#import "PPDocumentManager.h"
#import "PPLocalDocumentUploadQueue.h"

/** Scan results */
#import "PPScanResult.h"
#import "PPScanResultSerbia.h"
#import "PPScanResultAustria.h"
#import "PPElementCandidateList.h"
#import "PPElementCandidate.h"
#import "PPElementPosition.h"
#import "PPUserConfirmedValues.h"
#import "PPUserConfirmedValuesSerbia.h"
#import "PPUserConfirmedValuesAustria.h"

/** View controller headers */
#import "PPHomeViewControllerProtocol.h"
#import "PPDocumentsTableDataSource.h"

/** Utility headers */
#import "PPTableSection.h"
#import "PPTableViewDataSource.h"
#import "PPTableSectionCreator.h"
#import "PPTableLinearSectionCreator.h"
#import "PPDateSortedDocumentsSectionCreator.h"
#import "PPSplitTypeDocumentsSectionCreator.h"

/** Network */
#import "PPNetworkManager.h"
#import "PPUploadRequestOperation.h"
#import "PPDocumentsFetchDelegate.h"

/** PhotoPayCloudService */
#import "PPPhotoPayCloudService.h"

/** Utils */
#import "UIImage+Processing.h"
#import "UIApplication+Documents.h"

#endif /* _PHOTOPAY_CLOUD_ */
