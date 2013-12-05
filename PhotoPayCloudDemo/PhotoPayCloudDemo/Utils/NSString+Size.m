//
//  NSString+Size.m
//  PhotoPayFramework
//
//  Created by Jurica Cerovec on 7/16/13.
//  Copyright (c) 2013 Racuni.hr. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGFloat)pp_fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGFloat fontSize = [font pointSize];
    CGFloat height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    UIFont *newFont = font;
    
    //Reduce font size while too large, break if no height (empty string)
    while (height > size.height && height != 0) {
        fontSize -= 0.2;
        newFont = [UIFont fontWithName:font.fontName size:fontSize];
        height = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    };
    
    // Loop through words in string and resize to fit
    for (NSString *word in [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) {
        CGFloat width = [word sizeWithFont:newFont].width;
        while (width > size.width && width != 0) {
            fontSize -= 0.2;
            newFont = [UIFont fontWithName:font.fontName size:fontSize];
            width = [word sizeWithFont:newFont].width;
        }
    }
    return fontSize;
}

@end
