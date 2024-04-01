//
//  A4CropCornerView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A4Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface A4CropCornerView : UIView

@property (nonatomic, assign) A4CornerType cornerType;

@property (nonatomic, assign) CGPoint point;

@end

NS_ASSUME_NONNULL_END
