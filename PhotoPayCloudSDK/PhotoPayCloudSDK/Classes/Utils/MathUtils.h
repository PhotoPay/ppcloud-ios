//
//  MathUtils.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#ifndef PhotoPayCloudSDK_MathUtils_h
#define PhotoPayCloudSDK_MathUtils_h

static inline double dnorm(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
}

static inline double dclamp(double v, double min, double max) {
    if (v > max) {
        return max;
    } else if (v < min) {
        return min;
    } else {
        return v;
    }
}

#endif
