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

static CGFloat kLHGOpenCVEditingImageMargin = 20.0;

@interface LHGOpenCVEditingViewController () <LHGOpenCVCropFrameViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) LHGOpenCVCropFrameView *cropFrameView;
@property (strong, nonatomic) LHGOpenCVCropMagnifierView *magnifierView;//放大镜
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *previousBtn;
@property(nonatomic, strong) UIButton *nextBtn;
@property(nonatomic, strong) NSMutableArray *masonryViewArray;
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;
@property(nonatomic, strong) UIView * drawingBoardView;
@property(nonatomic, strong) UIView *footerView;
@end

@implementation LHGOpenCVEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.masonryViewArray = [NSMutableArray array];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:27.0/255 green:27.0/255 blue:27.0/255 alpha:1];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(64 + STATUS_HEIGHT);
    }];
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(headerView).mas_offset(-15);
        make.left.mas_equalTo(headerView).mas_offset(15);
        make.width.height.mas_equalTo(40);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"1/1";
    [headerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headerView);
        make.bottom.mas_equalTo(headerView).mas_offset(-25);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(20);
    }];
    
    self.drawingBoardView = [[UIView alloc] init];
    [self.view addSubview:self.drawingBoardView];
    self.drawingBoardView.frame = CGRectMake(0, 64 + STATUS_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - STATUS_HEIGHT*2 - 130);
    CGFloat navHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
    CGRect imageFrame = CGRectZero;
    imageFrame.origin.x = kLHGOpenCVEditingImageMargin;
    imageFrame.origin.y = kLHGOpenCVEditingImageMargin;
    imageFrame.size.width = CGRectGetWidth(self.drawingBoardView.frame) - kLHGOpenCVEditingImageMargin * 2;
    imageFrame.size.height = CGRectGetHeight(self.drawingBoardView.frame) - imageFrame.origin.y - kLHGOpenCVEditingImageMargin;
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    self.imageView.image = self.originImage;
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
    
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = [UIColor colorWithRed:27.0/255 green:27.0/255 blue:27.0/255 alpha:1];
    self.footerView.translatesAutoresizingMaskIntoConstraints= NO;//
    [self.view addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(44 + BOTTOM_HEIGHT);
    }];
    
    self.previousBtn = [[UIButton alloc] init];
    [self.footerView addSubview:self.previousBtn];
    [self.previousBtn setImage:[UIImage imageNamed:@"previousBtnT"] forState:UIControlStateNormal];
    [self.previousBtn setImage:[UIImage imageNamed:@"previousBtnF"] forState:UIControlStateSelected];

    UIButton *rotationBtn = [[UIButton alloc] init];
    [rotationBtn setImage:[UIImage imageNamed:@"rotationBtn"] forState:UIControlStateNormal];
    [rotationBtn addTarget:self action:@selector(bottomViewDidRotateClick) forControlEvents:UIControlEventTouchUpInside];
    rotationBtn.backgroundColor = [UIColor blackColor];
    rotationBtn.layer.cornerRadius = 12;
    [self.footerView addSubview:rotationBtn];
    [rotationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32).with.priorityHigh;
        make.height.mas_equalTo(32);
    }];
    UIButton *unfoldingBtn = [[UIButton alloc] init];
    [unfoldingBtn setImage:[UIImage imageNamed:@"unfoldingBtn"] forState:UIControlStateNormal];
    [unfoldingBtn addTarget:self action:@selector(paddingAllPoints) forControlEvents:UIControlEventTouchUpInside];
    unfoldingBtn.backgroundColor = [UIColor blackColor];
    unfoldingBtn.layer.cornerRadius = 12;
    [self.footerView addSubview:unfoldingBtn];
    [unfoldingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(32);
    }];
    self.nextBtn = [[UIButton alloc] init]; [self.nextBtn setImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.nextBtn];
    [self.masonryViewArray addObject:self.previousBtn];
    [self.masonryViewArray addObject:rotationBtn];
    [self.masonryViewArray addObject:unfoldingBtn];
    [self.masonryViewArray addObject:self.nextBtn];
    [self masonry_horizontal_fixSpace];
    
    self.autoDectorCorner = YES;
    
    if (self.autoDectorCorner) {
        //轮廓提取，并查找轮廓四个顶点
        [LHGOpenCVHelper asyncDetectQuadCornersWithImage:self.originImage targetSize:cropFrame.size completionHandler:^(NSDictionary<NSNumber *,NSValue *> * _Nullable quadPoints) {
            NSLog(@"识别出point----%d",quadPoints.count);
            // 创建一个 dispatch_group
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

- (void)paddingAllPoints {
    if (self.cropFrameView.isFullTag) {
        [self.cropFrameView resetDefaultPoints:40];
    } else {
        [self.cropFrameView paddingAllPoions];
    }
    self.cropFrameView.isFullTag = !self.cropFrameView.isFullTag;
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

- (void)dismissAction {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
}

- (void)masonry_horizontal_fixSpace {
    // 实现masonry水平固定间隔方法
    [self.masonryViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:84 leadSpacing:16 tailSpacing:16];
    
    // 设置array的垂直方向的约束
    [self.masonryViewArray mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.top.mas_greaterThanOrEqualTo(self.footerView).mas_offset(6);
        make.height.mas_lessThanOrEqualTo(32);
    }];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:true animated:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    [self.navigationController setNavigationBarHidden:false animated:animated];

}

@end
