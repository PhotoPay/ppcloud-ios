//
//  PPDocumentUploadingView.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentUploadingView.h"
#import "PPAlertView.h"

@implementation PPDocumentUploadingView

- (void)localDocument:(PPLocalDocument*)localDocument
didFinishUploadWithResult:(PPRemoteDocument*)remoteDocument {
    
}

- (void)localDocument:(PPLocalDocument*)localDocument
didFailToUploadWithError:(NSError*)error {
    
}

- (void)localDocument:(PPLocalDocument*)localDocument
didUpdateProgressWithBytesWritten:(long long)totalBytesWritten
    totalBytesToWrite:(long long)totalBytesToWrite {
    self.progressView.progress = totalBytesWritten / (float) totalBytesToWrite;
}

- (void)localDocumentDidCancelUpload:(PPLocalDocument*)localDocument {
    
}

- (void)setDocument:(PPDocument *)inDocument {
    document = inDocument;
    [[[inDocument localDocument] uploadRequest] setDelegate:self];
}

- (IBAction)cancelSend:(id)sender {
    [[[[self document] localDocument] uploadRequest] cancel];
    self.progressView.progress = 0;
}

- (IBAction)deleteDocument:(id)sender {
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
