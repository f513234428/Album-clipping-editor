//
//  A4Defines.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#ifndef A4Defines_h
#define A4Defines_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define CVLogDebug(args, ...) NSLog(args, ##__VA_ARGS__)
#else
#define CVLogDebug(args, ...)
#endif

typedef NS_ENUM(NSUInteger, A4CornerType) {
    A4CornerTypeOther         = 0,
    A4CornerTypeTopLeft       = 1,
    A4CornerTypeTopRight      = 2,
    A4CornerTypeBottomLeft    = 3,
    A4CornerTypeBottomRight   = 4,
    A4CornerTypeTopCenter     = 5,
    A4CornerTypeBottomCenter  = 6,
    A4CornerTypeLeftCenter    = 7,
    A4CornerTypeRightCenter   = 8,
};

#endif /* A4Defines_h */
