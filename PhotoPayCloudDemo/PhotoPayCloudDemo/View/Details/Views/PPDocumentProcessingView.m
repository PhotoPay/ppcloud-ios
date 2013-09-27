//
//  PPDocumentProcessingView.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/25/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentProcessingView.h"
#import "PPAlertView.h"

@implementation PPDocumentProcessingView

- (IBAction)deletePressed:(id)sender {
    PPAlertView* alertView = [[PPAlertView alloc] initWithTitle:_(@"PhotoPayDetailsDeleteDocumentAlertViewTitle")
                                                        message:_(@"PhotoPayDetailsDeleteDocumentAlertViewMessage")
                                                     completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                         if (buttonIndex == 1) {
                                                             NSError * __autoreleasing error = nil;
                                                             [[PPPhotoPayCloudService sharedService] deleteDocument:[self document] error:&error];
                                                             [[self delegate] documentDetailsViewWillClose:self];
                                                         }
                                                     }
                                              cancelButtonTitle:_(@"PhotoPayDetailsDeleteDocumentAlertViewCancel")
                                              otherButtonTitles:_(@"PhotoPayDetailsDeleteDocumentAlertViewDelete"), nil];
    [alertView show];
}
@end
