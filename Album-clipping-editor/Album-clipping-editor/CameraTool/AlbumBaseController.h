//
//  AlbumBaseController.h
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumBaseController : UIViewController
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

+(UIImage*)compressImage:(UIImage*)sourceImage toTargetWidth:(CGFloat)targetHeight;
+ (UIImage *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxSizeWithKB:(CGFloat) maxSize;
+ (UIImage *)scaleImage:(UIImage *)image size:(CGSize)size;
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;
- (void)flashButtonClick:(UIButton *)sender;
- (BOOL)resetFocusAndExposureModes;
- (void)focusAtPoint:(CGPoint)point;
- (void)initAVCaptureSession;
@end

NS_ASSUME_NONNULL_END
