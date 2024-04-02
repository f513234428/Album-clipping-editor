//
//  A4AlbumBaseController.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import "A4AlbumBaseController.h"

@interface A4AlbumBaseController ()
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 * 最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;


@end

@implementation A4AlbumBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    self.effectiveScale = 1.0;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    
    [device unlockForConfiguration];
        // Input
        self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        // Output
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecTypeJPEG,AVVideoCodecKey,nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        
        // Session
        self.session = [[AVCaptureSession alloc]init];
        //AVCaptureSessionPresetHigh:实现高质量的视频和音频输出
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        // addInput:可称为虽然会话正在运行
        if ([self.session canAddInput:self.videoInput])
        {
            [self.session addInput:self.videoInput];
        }
        
        if ([self.session canAddOutput:self.stillImageOutput])
        {
            [self.session addOutput:self.stillImageOutput];
        }
        
        self.previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.view.bounds;
        
        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self resetFocusAndExposureModes];
}

+(UIImage*)compressImage:(UIImage*)sourceImage toTargetWidth:(CGFloat)targetHeight {
    //获取原图片的大小尺寸
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    //根据目标图片的宽度计算目标图片的高度
//    CGFloat targetHeight = (targetWidth / width) * height;
    CGFloat targetWidth = (targetHeight / height) *width;
    //开启图片上下文
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    //绘制图片
    [sourceImage drawInRect:CGRectMake(0,0, targetWidth, targetHeight)];
    //从上下文中获取绘制好的图片
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图片上下文
    UIGraphicsEndImageContext();

    
    return newImage;
}

/// 调整图片尺寸和大小
/// @param sourceImage 原始图片
/// @param maxImageSize 新图片最大尺寸
/// @param maxSize 新图片最大存储大小（kb）
+ (UIImage *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxSizeWithKB:(CGFloat) maxSize{
   if (maxSize <= 0.0) maxSize = 1024.0;
   if (maxImageSize <= 0.0) maxImageSize = 1024.0;
   //先调整分辨率
   CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
   CGFloat tempHeight = newSize.height / maxImageSize;
   CGFloat tempWidth = newSize.width / maxImageSize;
   if (tempWidth > 1.0 && tempWidth > tempHeight) {
       newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
   } else if (tempHeight > 1.0 && tempWidth < tempHeight){
       newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
   }
   UIGraphicsBeginImageContext(newSize);
   [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   //调整大小
   NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
   CGFloat sizeOriginKB = imageData.length / 1024.0;
   CGFloat resizeRate = 0.9;
   while (sizeOriginKB > maxSize && resizeRate > 0.1) {
       imageData = UIImageJPEGRepresentation(newImage,resizeRate);
       sizeOriginKB = imageData.length / 1024.0;
       resizeRate -= 0.1;
   }
   return [UIImage imageWithData: imageData];
}


//获取设备方向
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

//打开闪光灯
- (void)flashButtonClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.isSelected == YES) { //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }else{//关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

//自动聚焦、曝光
- (BOOL)resetFocusAndExposureModes{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
        return YES;
    }
    else{
        NSLog(@"%@", error);
        return NO;
    }
}

//聚焦
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else{
            NSLog(@"%@", error);
            
        }
    }
}

- (BOOL)cameraSupportsTapToFocus {
    return [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] isFocusPointOfInterestSupported];
}


//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}

//// 原图等比放缩图片
+ (UIImage *)scaleImage:(UIImage *)image size:(CGSize)size
{
    @autoreleasepool {
        // 并把它设置成为当前正在使用的context
        //UIGraphicsBeginImageContext(size);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        // 绘制改变大小的图片
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh); /* 设置位图像素保真度 */
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        
        CGFloat maxW = size.width;
        CGFloat maxH = size.height;
        CGFloat scale = image.size.width/image.size.height;
        
        float wscale = image.size.width/maxW;
        float hscale = image.size.height/maxH;
        if (wscale > hscale) {
            width =  maxW;
            height = width/scale;
        }else {
            height =  maxH;
            width  =  height*scale;;
        }
        CGFloat x = size.width/2.0 - width/2.0;
        CGFloat y = size.height/2.0 - height/2.0;
        CGRect rect = CGRectMake(x, y, width, height);
        [image drawInRect:rect];
        // 从当前context中创建一个改变大小后的图片
        UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
        return imageOut;
    }

}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

@end
