//
//  LHGOpenCVEditingViewController.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "LHGOpenCVEditingViewController.h"
#import "UIImageView+LHGContentRect.h"
#import "LHGOpenCVCropFrameView.h"
#import "LHGOpenCVCropMagnifierView.h"
#import "LHGOpenCVUtils.h"
#import "LHGOpenCVHelper.h"
#import "Masonry.h"
#import <HXPhotoPicker.h>
#import "ShowPictureController.h"
#import "LHGOpenCVPhotoHelper.h"

static CGFloat kLHGOpenCVEditingImageMargin = 20.0;

@interface LHGOpenCVEditingViewController () <LHGOpenCVCropFrameViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) LHGOpenCVCropFrameView *cropFrameView;
@property (strong, nonatomic) LHGOpenCVCropMagnifierView *magnifierView;//放大镜
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;
@property(nonatomic, strong) UIView * drawingBoardView;

//@property(nonatomic, strong) UIScrollView *editView;
@end

@implementation LHGOpenCVEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bottomViewDidRotate:) name:@"bottomViewDidRotate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bottomViewPaddingAllPoints:) name:@"bottomViewPaddingAllPoints" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bottomViewNext:) name:@"bottomViewNext" object:nil];

    
    self.view.backgroundColor = [UIColor blackColor];
    self.drawingBoardView = [[UIView alloc] init];
    [self.view addSubview:self.drawingBoardView];
    self.drawingBoardView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - BOTTOM_HEIGHT - 108 - STATUS_HEIGHT);
    CGRect imageFrame = CGRectZero;
    imageFrame.origin.x = kLHGOpenCVEditingImageMargin;
    imageFrame.origin.y = kLHGOpenCVEditingImageMargin;
    imageFrame.size.width = CGRectGetWidth(self.drawingBoardView.frame) - kLHGOpenCVEditingImageMargin * 2;
    imageFrame.size.height = CGRectGetHeight(self.drawingBoardView.frame) - imageFrame.origin.y - kLHGOpenCVEditingImageMargin;
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    self.imageView.image = self.originPhoto.previewPhoto;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.drawingBoardView addSubview:self.imageView];
    
    CGRect cropFrame = [self.imageView shm_contentFrame];
    cropFrame.origin.x += imageFrame.origin.x;
    cropFrame.origin.y += imageFrame.origin.y;
    self.cropFrameView = [[LHGOpenCVCropFrameView alloc] initWithFrame:cropFrame];
    self.cropFrameView.delegate = self;
    [self.drawingBoardView addSubview:self.cropFrameView];
    
    self.magnifierView = [[LHGOpenCVCropMagnifierView alloc] init];
    [self.view addSubview:self.magnifierView];
    self.magnifierView.hidden = YES;
    
  
    self.autoDectorCorner = YES;
    [self openAutoDector];
    
}

- (void)bottomViewPaddingAllPoints:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    int tag = [[userInfo objectForKey:@"imageTag"] intValue];
    if (tag == self.imageTag) {
        [self paddingAllPoints];
    }
}
- (void)paddingAllPoints {
    if (self.cropFrameView.isFullTag) {
        [self.cropFrameView resetDefaultPoints:40];
    } else {
        [self.cropFrameView paddingAllPoions];
    }
    self.cropFrameView.isFullTag = !self.cropFrameView.isFullTag;
}
- (void)bottomViewNext:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    int tag = [[userInfo objectForKey:@"imageTag"] intValue];
    if (tag == self.imageTag) {
        [[LHGOpenCVPhotoHelper sharedHelper] savePhoto:self.originPhoto];
    }
}
- (void)bottomViewDidRotate:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    int tag = [[userInfo objectForKey:@"imageTag"] intValue];
    if (tag == self.imageTag) {
        [self bottomViewDidRotateClick];
    }
}
- (void)bottomViewDidRotateClick {
    UIImage *image = [self.imageView.image hx_rotationImage:UIImageOrientationLeft];
    self.imageWidth = image.size.width;
    self.imageHeight = image.size.height;
    CGRect imageRect = [self getImageFrame];
    self.imageView.center = self.drawingBoardView.center;
    [UIView animateWithDuration:0.2 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.imageView.frame = imageRect;
        [self.cropFrameView reloadCropFrame:imageRect];
    } completion:^(BOOL finished) {
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.image = image;
        self.imageView.frame = imageRect;
    }];
}

- (void)openAutoDector {
    if (self.autoDectorCorner) {
        //轮廓提取，并查找轮廓四个顶点
        [LHGOpenCVHelper asyncDetectQuadCornersWithImage:self.originPhoto.previewPhoto targetSize:self.cropFrameView.frame.size completionHandler:^(NSDictionary<NSNumber *,NSValue *> * _Nullable quadPoints) {
            // 创建一个 dispatch_group 异步block结果返回后同步刷新UI
            dispatch_group_t group = dispatch_group_create();
            if (quadPoints.count == 4) {
                dispatch_group_enter(group);
                dispatch_group_enter(group);
                dispatch_group_enter(group);
                dispatch_group_enter(group);
                [quadPoints enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSValue * _Nonnull obj, BOOL * _Nonnull stop) {
                    [self.cropFrameView updatePointValue:obj.CGPointValue cornerType:key.integerValue];
                    dispatch_group_leave(group);
                }];
                // 在所有操作完成后执行外部的方法
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    [self.cropFrameView updateCenterPointType:LHGOpenCVCornerTypeTopLeft];
                    [self.cropFrameView updateCenterPointType:LHGOpenCVCornerTypeBottomRight];
                });
            }
        }];
    }
}

- (CGRect)getImageFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat bottomMargin = hxBottomMargin + 100;
    CGFloat leftRightMargin = 40;
    CGFloat imageY = HX_IS_IPhoneX_All ? 84 : 30;
    if (HX_IS_IPhoneX_All && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        bottomMargin = 21;
        leftRightMargin = 80;
        imageY = 20;
    }
    CGFloat width = self.view.hx_w - leftRightMargin;
    CGFloat height = self.view.frame.size.height - 100 - imageY - bottomMargin;
    CGFloat imgWidth = self.imageWidth;
    CGFloat imgHeight = self.imageHeight;
    CGFloat w;
    CGFloat h;
    
    if (imgWidth > width) {
        imgHeight = width / imgWidth * imgHeight;
    }
    if (imgHeight > height) {
        w = height / self.imageHeight * imgWidth;
        h = height;
    }else {
        if (imgWidth > width) {
            w = width;
        }else {
            w = imgWidth;
        }
        h = imgHeight;
    }
    return CGRectMake((width - w) / 2 + leftRightMargin / 2, imageY + (height - h) / 2, w, h);
}


- (void)done {
    if (![self.cropFrameView isQuadEffective]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"所选区域无效" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    UIImage * exportImg = [self.cropFrameView exportEditPhoto:self.imageView];
    ShowPictureController *vc = [[ShowPictureController alloc] init];
    vc.showImage = exportImg;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - LHGOpenCVCropFrameViewDelegate

- (void)cropFrameView:(LHGOpenCVCropFrameView *)cropFrameView didMoveToPoint:(CGPoint)point state:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan) {
        self.magnifierView.hidden = NO;
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        self.magnifierView.hidden = YES;
    }
    
    CGPoint renderPoint = [cropFrameView convertPoint:point toView:self.view];
    [self.magnifierView updateRenderPoint:renderPoint renderView:self.view];
    CGPoint magnifierCenter = [cropFrameView convertPoint:point toView:self.magnifierView.superview];
    magnifierCenter.y -= self.magnifierView.frame.size.height;
    self.magnifierView.center = magnifierCenter;
    
    [[LHGOpenCVPhotoHelper sharedHelper] setCurrentPhotoCanSave:[self.cropFrameView isQuadEffective]];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}


@end
