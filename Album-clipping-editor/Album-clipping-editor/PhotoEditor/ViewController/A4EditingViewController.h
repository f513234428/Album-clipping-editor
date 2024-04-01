//
//  A4EditingViewController.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPhotoModel.h"

@class A4EditingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol A4EditingViewControllerDelegate <NSObject>

@optional
//- (void)editingController:(A4EditingViewController *)editor didFinishCropping:(UIImage *)finalCropImage;

@end

@interface A4EditingViewController : UIViewController

@property (nonatomic, weak) id<A4EditingViewControllerDelegate> delegate;

//@property (nonatomic, strong) UIImage *originImage;
@property(nonatomic, strong) HXPhotoModel *originPhoto;
// 自动提取四边形四个顶点
@property (nonatomic, assign) BOOL autoDectorCorner;
@property(nonatomic, assign) int imageTag;

@end

NS_ASSUME_NONNULL_END
