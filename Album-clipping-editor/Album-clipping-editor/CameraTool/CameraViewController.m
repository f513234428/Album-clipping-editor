//
//  CameraView.m
//  Camera
//
//  Created by wzh on 2017/6/2.
//  Copyright © 2017年 wzh. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <HXPhotoPicker.h>
#import "ReLayoutButton.h"
#import <JSBadgeView.h>
#import "AlbumPictureArrView.h"
#import <Masonry.h>
#import "LHGOpenCVEditingViewController.h"

@interface CameraViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,HXPhotoViewDelegate,LHGOpenCVEditingViewControllerDelegate>
@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;

@property (nonatomic, strong) NSData  *jpegData;

@property (nonatomic, assign) CFDictionaryRef attachments;

@property (nonatomic, strong) UIView *toolView;

@property (nonatomic, strong) UIView *editorView;

@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property(nonatomic, assign) BOOL original;
@property(nonatomic, strong) NSMutableArray *selectList;
@property(nonatomic, strong) HXPhotoManager *photoManager;
@property(nonatomic, strong) AlbumPictureArrView *photoBtn;
@property(nonatomic, strong) ReLayoutButton *withdrawBtn;
@property(nonatomic, strong) JSBadgeView *badgeView;
@property(nonatomic, assign) BOOL isTakePicture;
@property(nonatomic, strong) AlbumPictureArrView *photoArrBtnView;
@end

@implementation CameraViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectList = [[NSMutableArray alloc] init];
    [self getPhotoLibraryAuthorization];
    [self createQueue];
    [self initAVCaptureSession];
    [self setUpGesture];
    [self createdTool];
    
}

- (void)createQueue{
    //单独弄一个线程管理摄像头启动,不会有警报
    dispatch_queue_t sessionQueue = dispatch_queue_create("camera session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
}

- (void)createdTool
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(64 + STATUS_HEIGHT);
    }];
    
    UIButton *headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [headerBtn setImage:[UIImage imageNamed:@"cancle"] forState:UIControlStateNormal];
    [headerBtn addTarget:self action:@selector(cancleCamera) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerBtn];
    [self.navigationController.navigationBar.subviews.lastObject setHidden:YES];
    [headerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(headerView);
        make.bottom.mas_equalTo(headerView).mas_offset(-15);
        make.left.mas_equalTo(headerView).mas_offset(20);
        make.width.height.mas_equalTo(40);
    }];
    
    UIButton *lampBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lampBtn setImage:[UIImage imageNamed:@"openFlish"] forState:UIControlStateSelected];
    [lampBtn setImage:[UIImage imageNamed:@"closeFlish"] forState:UIControlStateNormal];
    [lampBtn addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:lampBtn];
    [self.navigationController.navigationBar.subviews.lastObject setHidden:YES];
    [lampBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(headerView);
        make.bottom.mas_equalTo(headerView).mas_offset(-15);
        make.right.mas_equalTo(headerView).mas_offset(-20);
        make.width.height.mas_equalTo(40);
    }];
    
    self.toolView = [[UIView alloc] init];
    self.toolView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.width.mas_equalTo(self.view);
        make.height.mas_equalTo(120);
    }];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(takePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:cameraBtn];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.toolView);
        make.width.height.mas_equalTo(72);
    }];
    
    self.photoBtn = [[AlbumPictureArrView alloc] init];
    self.photoBtn.photoLabel.text = @"Local Upload";
    [self.photoBtn.photoView setImage:[UIImage imageNamed:@"cameraPhoto"] ];
    [self.photoBtn setPhotoStyle];
    @weakify(self);
    //点击回调
    [self.photoBtn tapActionGesture:^{
        [weak_self openCamera];
    }];
    
    [self.toolView addSubview:self.photoBtn];
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.toolView);
        make.width.height.mas_equalTo(72);
    }];
    
    self.withdrawBtn = [[ReLayoutButton alloc] init];
    [self.withdrawBtn setImage:[UIImage imageNamed:@"backPhoto"] forState:UIControlStateNormal];
    [self.withdrawBtn addTarget:self action:@selector(withdrawAction) forControlEvents:UIControlEventTouchUpInside];
    self.withdrawBtn.hidden = YES;
    [self.toolView addSubview:self.withdrawBtn];
    [self.withdrawBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.toolView);
        make.width.height.mas_equalTo(72);
    }];
    
    [self.photoArrBtnView.photoView setImage:[UIImage imageNamed:@"cameraPhoto"] ];
    self.photoArrBtnView.hidden = YES;
    [self.toolView addSubview:self.photoArrBtnView];
    [self.photoArrBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.toolView).offset(-20);
        make.centerY.mas_equalTo(self.toolView);
        make.width.height.mas_equalTo(72);
    }];
    //点击回调
    [self.photoArrBtnView tapActionGesture:^{
        [weak_self jumpPictureReaderView];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:true animated:animated];


    if (self.session) {
        @weakify(self);
        dispatch_async(self.sessionQueue, ^{
            @strongify(self);
            [self.session startRunning];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    [self.navigationController setNavigationBarHidden:false animated:animated];

    if (self.session) {
        @weakify(self);
        dispatch_async(self.sessionQueue, ^{
            @strongify(self);
            [self.session stopRunning];
        });
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    [self focusAtPoint:point];
}

- (void)getPhotoLibraryAuthorization {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status == PHAuthorizationStatusAuthorized) {
            [self getFirstPhoto]; //用户同意了
        }
    }];
}

- (void)getFirstPhoto {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    if (fetchResult.count > 0) {
        PHAsset *firstAsset = fetchResult.lastObject;
        [[PHImageManager defaultManager] requestImageForAsset:firstAsset
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeDefault
                                                      options:nil
                                                resultHandler:^(UIImage *image, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 使用这张图片
//                UIImage *compressionImg = [CameraViewController compressImage:image toTargetWidth:200];
                UIImage *compressionImg = [CameraViewController reSizeImageData:image maxImageSize:150 maxSizeWithKB:50];
//                UIImage *compressionImg = [image hx_scaleToFitSize:CGSizeMake(50, 50)];
                [self.photoBtn.photoView setImage: compressionImg];

            });
        }];
    }
}

//照相
- (void)takePhotoButtonClick {
    _stillImageConnection = [self.stillImageOutput        connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [_stillImageConnection setVideoOrientation:avcaptureOrientation];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:jpegData];
        HXPhotoModel *model = [HXPhotoModel photoModelWithImage:image];
        [self.selectList addObject:model];

        self.isTakePicture = YES;
        [self dealWithTakePicture];
    }];
}

- (void) dealWithTakePicture {
    if (self.isTakePicture ) {
        [self getPhotoArrLast];
        self.photoBtn.hidden = YES;
        self.withdrawBtn.hidden = NO;
        self.photoArrBtnView.hidden = NO;
    } else {
        self.photoBtn.hidden = NO;
        self.withdrawBtn.hidden = YES;
        self.photoArrBtnView.hidden = YES;
    }
}

//撤回
- (void)withdrawAction {
    if (self.selectList.count != 0) {
        [self.selectList removeLastObject];
    }
    if (self.selectList.count == 0) {
        self.isTakePicture = NO;
        self.badgeView.badgeText = nil;
    } else {
        self.isTakePicture = YES;
    }
    [self dealWithTakePicture];
}

- (void)getPhotoArrLast {
    HXPhotoModel *model = self.selectList.lastObject;
    UIImage *compressionImg = [CameraViewController reSizeImageData:model.previewPhoto maxImageSize:50 maxSizeWithKB:100];
    [self.photoArrBtnView.photoView setImage:compressionImg];

    self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectList.count];

}

//拍照之后调到相片详情页面
-(void)jumpPictureReaderView{
    LHGOpenCVEditingViewController *vc = [[LHGOpenCVEditingViewController alloc] init];
    vc.delegate = self;
    HXPhotoModel *photoModel = self.selectList.lastObject;
    vc.originImage = photoModel.previewPhoto;
    NSLog(@"跳转相片详情页面");
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)cancleCamera
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- TakePhotoDelegate
- (void)takePhoto:(UIImage *)image
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CameraTakePhoto:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate CameraTakePhoto:image];
    }
}

//添加手势代理
- (void)setUpGesture
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

//打开相册
- (void)openCamera
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hx_presentSelectPhotoControllerWithManager:self.photoManager delegate:self];
    });
}

#pragma mark -- ClipPhotoDelegate
- (void)clipPhoto:(UIImage *)image
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CameraTakePhoto:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate CameraTakePhoto:image];
    }
}

#pragma mark -- HXPhotoViewDelegate
- (void)photoView:(HXPhotoView *)photoView changeComplete:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal {
    self.original = isOriginal;
    self.selectList = [NSMutableArray arrayWithArray:allList];
    NSSLog(@"%@,%lu",allList,(unsigned long)allList.count);
}

#pragma mark - LHGOpenCVEditingViewControllerDelegate

- (void)editingController:(LHGOpenCVEditingViewController *)editor didFinishCropping:(UIImage *)finalCropImage {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:500];
    imageView.image = finalCropImage;
    NSSLog(@"LHGOpenCV回调--%@",imageView);

}

- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhoto];
        _photoManager.configuration.saveSystemAblum = YES;
        _photoManager.configuration.photoMaxNum = 0;
        _photoManager.configuration.videoMaxNum = 0;
        _photoManager.configuration.maxNum = 10;
        _photoManager.configuration.selectTogether = NO;
        _photoManager.configuration.photoCanEdit = YES;
        _photoManager.configuration.videoCanEdit = NO;
    }
    return _photoManager;
}

- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[JSBadgeView alloc] initWithParentView:self.photoArrBtnView.photoBGView alignment:JSBadgeViewAlignmentTopRight];
        _badgeView.badgeBackgroundColor = KBadgeColor;
    }
    return _badgeView;
}
- (AlbumPictureArrView *)photoArrBtnView {
    if (!_photoArrBtnView) {
        _photoArrBtnView = [[AlbumPictureArrView alloc] init];
    }
    return _photoArrBtnView;
}
@end
