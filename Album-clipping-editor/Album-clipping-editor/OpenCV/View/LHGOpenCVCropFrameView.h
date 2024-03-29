//
//  LHGOpenCVCropFrameView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHGOpenCVDefines.h"

@class LHGOpenCVCropFrameView;

NS_ASSUME_NONNULL_BEGIN

@protocol LHGOpenCVCropFrameViewDelegate <NSObject>

@optional
- (void)cropFrameView:(LHGOpenCVCropFrameView *)cropFrameView didMoveToPoint:(CGPoint)point state:(UIGestureRecognizerState)state;

@end

@interface LHGOpenCVCropFrameView : UIView

@property (nonatomic, weak) id<LHGOpenCVCropFrameViewDelegate> delegate;

@property (nonatomic, strong) UIColor *cornerFillColor;

@property (nonatomic, strong) UIColor *lineSuccessColor;

@property (nonatomic, strong) UIColor *lineFailureColor;

// 有效矩形区域
@property (nonatomic, assign) BOOL isQuadEffective;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updatePointValue:(CGPoint)point cornerType:(LHGOpenCVCornerType)cornerType;
- (void)reloadCropFrame:(CGRect)frame;
- (void)paddingAllPoions;
- (void)resetDefaultPoints:(CGFloat)offset;
- (void)updateCenterPointType:(LHGOpenCVCornerType)cornerType ;
- (CGPoint)pointValueWithCornerType:(LHGOpenCVCornerType)cornerType;
- (UIImage *)exportEditPhoto:(UIImageView *)imageView;
@property(nonatomic, assign) bool isFullTag;
@end

NS_ASSUME_NONNULL_END
