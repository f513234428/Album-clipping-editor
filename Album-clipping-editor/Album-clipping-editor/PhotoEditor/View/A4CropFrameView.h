//
//  A4CropFrameView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A4Defines.h"

@class A4CropFrameView;

NS_ASSUME_NONNULL_BEGIN

@protocol A4CropFrameViewDelegate <NSObject>

@optional
- (void)cropFrameView:(A4CropFrameView *)cropFrameView didMoveToPoint:(CGPoint)point state:(UIGestureRecognizerState)state;

@end

@interface A4CropFrameView : UIView

@property (nonatomic, weak) id<A4CropFrameViewDelegate> delegate;

@property (nonatomic, strong) UIColor *cornerFillColor;

@property (nonatomic, strong) UIColor *lineSuccessColor;

@property (nonatomic, strong) UIColor *lineFailureColor;

// 有效矩形区域
@property (nonatomic, assign) BOOL isQuadEffective;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updatePointValue:(CGPoint)point cornerType:(A4CornerType)cornerType;
- (void)reloadCropFrame:(CGRect)frame;
- (void)paddingAllPoions;
- (void)resetDefaultPoints:(CGFloat)offset;
- (void)updateCenterPointType:(A4CornerType)cornerType ;
- (CGPoint)pointValueWithCornerType:(A4CornerType)cornerType;
- (UIImage *)exportEditPhoto:(UIImageView *)imageView;
@property(nonatomic, assign) bool isFullTag;
@end

NS_ASSUME_NONNULL_END
