//
//  LHGOpenCVToolController.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/29.
//

#import "LHGOpenCVToolController.h"
#import "LHGOpenCVEditingViewController.h"
#import <HXPhotoPicker.h>
#import <Masonry.h>
#import "LHGOpenCVPhotoHelper.h"

@interface LHGOpenCVToolController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) UIImage *originImage;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *footerView;
@property(nonatomic, strong) NSMutableArray *masonryViewArray;//底部工具栏约束
@property(nonatomic, strong) UIButton *previousBtn;
@property(nonatomic, strong) UIButton *nextBtn;
@property(nonatomic, assign) BOOL isCanTouch;
@property(nonatomic, strong) NSMutableArray *editClipArry;//编辑过的图片数组
@end

@implementation LHGOpenCVToolController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentIndex = 0;
    self.masonryViewArray = [NSMutableArray array];
    self.editClipArry = [NSMutableArray array];
    self.isCanTouch = YES;

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

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + STATUS_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-64 - STATUS_HEIGHT-44 - BOTTOM_HEIGHT)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0);
    [self.view addSubview:self.scrollView];
    
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
    self.previousBtn.enabled = NO;
    [self.previousBtn setImage:[UIImage imageNamed:@"previousBtnT"] forState:UIControlStateNormal];
    [self.previousBtn setImage:[UIImage imageNamed:@"previousBtnF"] forState:UIControlStateDisabled];
    [self.previousBtn addTarget:self action:@selector(previousButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rotationBtn = [[UIButton alloc] init];
    [rotationBtn setImage:[UIImage imageNamed:@"rotationBtn"] forState:UIControlStateNormal];
    [rotationBtn addTarget:self action:@selector(sendBottomViewDidRotate) forControlEvents:UIControlEventTouchUpInside];
    rotationBtn.backgroundColor = [UIColor blackColor];
    rotationBtn.layer.cornerRadius = 12;
    [self.footerView addSubview:rotationBtn];
    [rotationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32).with.priorityHigh;
        make.height.mas_equalTo(32);
    }];
    
    UIButton *unfoldingBtn = [[UIButton alloc] init];
    [unfoldingBtn setImage:[UIImage imageNamed:@"unfoldingBtn"] forState:UIControlStateNormal];
    [unfoldingBtn addTarget:self action:@selector(sendBottomViewPaddingAllPoints) forControlEvents:UIControlEventTouchUpInside];
    unfoldingBtn.backgroundColor = [UIColor blackColor];
    unfoldingBtn.layer.cornerRadius = 12;
    [self.footerView addSubview:unfoldingBtn];
    [unfoldingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(32);
    }];
    
    self.nextBtn = [[UIButton alloc] init]; 
    [self.nextBtn setImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.nextBtn];
    [self.masonryViewArray addObject:self.previousBtn];
    [self.masonryViewArray addObject:rotationBtn];
    [self.masonryViewArray addObject:unfoldingBtn];
    [self.masonryViewArray addObject:self.nextBtn];
    [self masonry_horizontal_fixSpace];
    
    NSUInteger numberOfViewControllers = self.originImageArr.count;
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    for (int i = 0; i < numberOfViewControllers; i++) {
        // 创建新的ViewController
        LHGOpenCVEditingViewController *contentViewController = [[LHGOpenCVEditingViewController alloc] init];
        HXPhotoModel *model = self.originImageArr[i];
        contentViewController.originPhoto = model;
        contentViewController.imageTag = i;
        // 设置每个ViewController的frame
        contentViewController.view.frame = CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, self.scrollView.frame.size.height);
        
        // 添加到ScrollView中
        [self.scrollView addSubview:contentViewController.view];
        
        // 如果使用UIViewController的方式，记得将其添加为子控制器
        [self addChildViewController:contentViewController];
    }
    
    // 设置contentSize
    self.scrollView.contentSize = CGSizeMake(scrollViewWidth * numberOfViewControllers, self.scrollView.frame.size.height);
    self.titleLabel.text = [NSString stringWithFormat:@"%d/%lu",1,(unsigned long)self.originImageArr.count];

}

- (void)previousButtonTapped {
    if (self.currentIndex > 0 && self.isCanTouch) {
        [[LHGOpenCVPhotoHelper sharedHelper] removePhotoArrIndex:self.currentIndex];
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x -= self.view.frame.size.width;
        [self.scrollView setContentOffset:contentOffset animated:YES];
        self.currentIndex--;
        self.isCanTouch = NO;
        [self updateImageView];
        self.titleLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)self.currentIndex + 1,(unsigned long)self.originImageArr.count];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isCanTouch = YES;
        });
    } else {
        NSLog(@"已经是第一张了");
        
    }
}

- (void)nextButtonTapped {
    NSLog(@"当前第%lu张",(unsigned long)(self.currentIndex + 1));
    if (![[LHGOpenCVPhotoHelper sharedHelper] isCanSavePhoto]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"所选区域无效" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    if (self.currentIndex < _originImageArr.count - 1 && self.isCanTouch) {
        NSString* tag = [NSString stringWithFormat:@"%lu",(unsigned long)_currentIndex];
        NSDictionary *userInfo = @{@"imageTag": tag};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bottomViewNext" object:nil userInfo:userInfo];
        
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x += self.view.frame.size.width;
        [self.scrollView setContentOffset:contentOffset animated:YES];
        self.isCanTouch = NO;
        _currentIndex++;
        [self updateImageView];
        self.titleLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)self.currentIndex + 1,(unsigned long)self.originImageArr.count];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isCanTouch = YES;
        });
    } else if (self.currentIndex == self.originImageArr.count - 1) {
        NSLog(@"所有完成");
        NSMutableArray *editPhotoArr = [[LHGOpenCVPhotoHelper sharedHelper] getEditPhotoArr];
    }
}

// 更新图片显示
- (void)updateImageView {
    if (self.currentIndex < self.originImageArr.count) {
        HXPhotoModel *model = _originImageArr[_currentIndex];
        _originImage = model.previewPhoto;
    }
    if (self.currentIndex == 0) {
        self.previousBtn.enabled = NO;
    } else {
        self.previousBtn.enabled = YES;
    }
    if (self.currentIndex == self.originImageArr.count - 1) {
        [self.nextBtn setImage:[UIImage imageNamed:@"doneBtn"] forState:UIControlStateNormal];
    } else {
        [self.nextBtn setImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
    }
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

- (void)sendBottomViewDidRotate {
    NSString* tag = [NSString stringWithFormat:@"%lu",(unsigned long)_currentIndex];
    NSDictionary *userInfo = @{@"imageTag": tag};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bottomViewDidRotate" object:nil userInfo:userInfo];

}

- (void)sendBottomViewPaddingAllPoints {
    NSString* tag = [NSString stringWithFormat:@"%lu",(unsigned long)_currentIndex];
    NSDictionary *userInfo = @{@"imageTag": tag};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bottomViewPaddingAllPoints" object:nil userInfo:userInfo];

}

- (void)dismissAction {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
