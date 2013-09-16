//
//  main.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

//#import <UIKit/UIKit.h>
//
//#import "PPAppDelegate.h"
//
//int main(int argc, char *argv[])
//{
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PPAppDelegate class]));
//    }
//}

// Fix for annoying "AssertMacros: queueEntry" debug log outputs
// @see https://devforums.apple.com/thread/197966?start=75&tstart=0
// Seems to be Xcode5 beta problem. TODO: return the above commented code when fixed in Xcode5.

#import <UIKit/UIKit.h>

#import "PPAppDelegate.h"

typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
    if ( strncmp(buffer, "AssertMacros:", 13) == 0 ) {
        return 0;
    }
    return _oldStdWrite(inFD, buffer, size);
}

int main(int argc, char *argv[])
{
    _oldStdWrite = stderr->_write;
    stderr->_write = __pyStderrWrite;
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PPAppDelegate class]));
    }
}
