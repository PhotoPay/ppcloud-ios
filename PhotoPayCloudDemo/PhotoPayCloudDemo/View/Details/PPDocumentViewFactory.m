//
//  PPDocumentViewFactory.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentViewFactory.h"
#import "PPDocumentUploadingView.h"
#import "PPDocumentUploadFailedView.h"

@interface PPDocumentViewFactory ()

@property (nonatomic, strong) PPDocumentDetailsView* currentView;
@property (nonatomic, assign) PPDocumentState currentDocumentState;

@end

@implementation PPDocumentViewFactory

@synthesize currentView;
@synthesize document;
@synthesize currentDocumentState;

- (id)initWithDocument:(PPDocument*)inDocument {
    self = [super init];
    if (self) {
        self.document = inDocument;
        currentView = nil;
        currentDocumentState = PPDocumentStateUnknown;
    }
    return self;
}

- (void)setDocument:(PPDocument *)inDocument {
    document = inDocument;
}

NSUInteger stateGroupForState(PPDocumentState state) {
    switch (state) {
        case PPDocumentStateUploadFailed:
            return 0;
        case PPDocumentStateCreated:
        case PPDocumentStateStored:
        case PPDocumentStateUploading:
            return 1;
        case PPDocumentStateProcessed:
            return 2;
        case PPDocumentStateReceived:
        case PPDocumentStatePending:
        case PPDocumentStateProcessing:
        case PPDocumentStateProcessingError:
        default:
            return 3;
    }
}

- (PPDocumentDetailsView*)documentView {
    if (stateGroupForState(currentDocumentState) != stateGroupForState([document state]) || currentView == nil) {
        currentDocumentState = [document state];

        NSLog(@"State is %@", [PPDocument objectForDocumentState:[document state]]);
        
        switch (currentDocumentState) {
            case PPDocumentStateUploadFailed:
                if (IS_IPAD) {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPDocumentUploadFailedView_iPhone" owner:self options:nil] objectAtIndex:0];
                } else {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPDocumentUploadFailedView_iPhone" owner:self options:nil] objectAtIndex:0];
                }
                break;

            case PPDocumentStateCreated:
            case PPDocumentStateStored:
            case PPDocumentStateUploading:
                if (IS_IPAD) {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPDocumentUploadingView_iPhone" owner:self options:nil] objectAtIndex:0];
                } else {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPDocumentUploadingView_iPhone" owner:self options:nil] objectAtIndex:0];
                }
                
                ((PPDocumentUploadingView*)currentView).progressView.progress = [[[[[self document] localDocument] uploadRequest] progress] floatValue];
                break;
                
            case PPDocumentStateProcessed:
                if (IS_IPAD) {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPProcessedDocumentView_iPhone" owner:self options:nil] objectAtIndex:0];
                } else {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPProcessedDocumentView_iPhone" owner:self options:nil] objectAtIndex:0];
                }
                break;
                
            case PPDocumentStateReceived:
            case PPDocumentStatePending:
            case PPDocumentStateProcessing:
            case PPDocumentStateProcessingError:
            default:
                if (IS_IPAD) {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPDocumentProcessingView_iPhone" owner:self options:nil] objectAtIndex:0];
                } else {
                    currentView = [[[NSBundle mainBundle] loadNibNamed:@"PPDocumentProcessingView_iPhone" owner:self options:nil] objectAtIndex:0];
                }
                break;
        }
        
        [currentView setDocument:[self document]];
    }
    return currentView;
}

@end
