//
//  StyledPageControl.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 12/04/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    PageControlStyleDefault = 0,
    PageControlStyleStrokedCircle = 1,
    PageControlStylePressed1 = 2,
    PageControlStylePressed2 = 3,
    PageControlStyleWithPageNumber = 4,
    PageControlStyleThumb = 5
} PageControlStyle;

@interface PPStyledPageControl : UIControl

@property (nonatomic, strong) UIColor *coreNormalColor, *coreSelectedColor;
@property (nonatomic, strong) UIColor *strokeNormalColor, *strokeSelectedColor;
@property (nonatomic, assign) NSInteger currentPage, numberOfPages;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) PageControlStyle pageControlStyle;
@property (nonatomic, assign) int strokeWidth, diameter, gapWidth;
@property (nonatomic, strong) UIImage *thumbImage, *selectedThumbImage;
@property (nonatomic, strong) NSMutableDictionary *thumbImageForIndex, *selectedThumbImageForIndex;

- (void)setThumbImage:(UIImage *)aThumbImage forIndex:(NSInteger)index;

- (UIImage *)thumbImageForIndex:(NSInteger)index;

- (void)setSelectedThumbImage:(UIImage *)aSelectedThumbImage forIndex:(NSInteger)index;

- (UIImage *)selectedThumbImageForIndex:(NSInteger)index;

@end
