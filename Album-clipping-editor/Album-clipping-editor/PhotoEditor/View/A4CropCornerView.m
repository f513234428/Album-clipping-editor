//
//  A4CropCornerView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "A4CropCornerView.h"

@implementation A4CropCornerView

- (void)setPoint:(CGPoint)point {
    self.center = point;
}

- (CGPoint)point {
    return self.center;
}

@end
