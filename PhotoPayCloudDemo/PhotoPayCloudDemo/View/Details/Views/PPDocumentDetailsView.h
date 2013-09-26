//
//  PPDocumentDetailsView.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/18/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotoPayCloud/PhotoPayCloud.h>

@protocol PPDocumentDetailsViewDelegate;

@interface PPDocumentDetailsView : UIView {
    
@protected
    PPDocument* document;
}

@property (nonatomic, strong) PPDocument *document;

@property (nonatomic, weak) id<PPDocumentDetailsViewDelegate> delegate;

@end

@protocol PPDocumentDetailsViewDelegate

@required

- (void)documentDetailsViewWillClose:(PPDocumentDetailsView*)detailsView;

- (void)documentDetailsView:(PPDocumentDetailsView*)detailsView
          didMakeViewActive:(UIView*)activeView;

- (void)documentDetailsViewDidMakeViewInactive:(PPDocumentDetailsView*)detailsView;

@end

