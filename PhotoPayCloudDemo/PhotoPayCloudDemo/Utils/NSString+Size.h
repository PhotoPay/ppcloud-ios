//
//  NSString+Size.h
//  PhotoPayFramework
//
//  Created by Jurica Cerovec on 7/16/13.
//  Copyright (c) 2013 Racuni.hr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

- (CGFloat)pp_fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end
