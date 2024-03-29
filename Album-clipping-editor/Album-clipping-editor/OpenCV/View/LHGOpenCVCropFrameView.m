//
//  LHGOpenCVCropFrameView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "LHGOpenCVCropFrameView.h"
#import "LHGOpenCVCropCornerView.h"
#import "UIImageView+LHGContentRect.h"

#define kCropButtonSize 20
#define kCropButtonMargin 40

@interface LHGOpenCVCropFrameView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *topLeftView;
@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *topRightView;
@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *bottomLeftView;
@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *bottomRightView;
@property (nonatomic, weak) LHGOpenCVCropCornerView *activeCornerView;
@property (nonatomic, copy) NSArray <UIView*> *allCornerViews;

@property (nonatomic, strong) LHGOpenCVCropCornerView *topCenterView;
@property (nonatomic, strong) LHGOpenCVCropCornerView *bottomCenterView;
@property (nonatomic, strong) LHGOpenCVCropCornerView *leftCenterView;
@property (nonatomic, strong) LHGOpenCVCropCornerView *rightCenterView;

@property(nonatomic, strong) NSMutableArray *originalPositions;//坐标保存数组
@end

@implementation LHGOpenCVCropFrameView
@synthesize lineSuccessColor = _lineSuccessColor;
@synthesize cornerFillColor = _cornerFillColor;

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.originalPositions = [NSMutableArray array];
        
        UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePan:)];
        singlePan.maximumNumberOfTouches = 1;
        singlePan.delegate = self;
        [self addGestureRecognizer:singlePan];
        
        for (UIView *cornerView in self.allCornerViews) {
            [self addSubview:cornerView];
        }
        [self resetDefaultPoints: kCropButtonMargin];
    }
    return self;
}

- (void)reloadCropFrame:(CGRect)frame {
    self.frame = frame;
    [self resetDefaultPoints: kCropButtonMargin];
}

- (void)resetDefaultPoints:(CGFloat)offset {

//    CGFloat offset = kCropButtonMargin;
    self.topLeftView.point = CGPointMake(offset, offset);
    self.topRightView.point = CGPointMake(self.bounds.size.width - offset, offset);
    self.bottomLeftView.point = CGPointMake(offset, self.bounds.size.height - offset);
    self.bottomRightView.point = CGPointMake(self.bounds.size.width - offset, self.bounds.size.height - offset);
    
    self.topCenterView.point = CGPointMake(self.bounds.size.width/2, offset);
    self.bottomCenterView.point = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - offset);
    self.leftCenterView.point = CGPointMake(offset, self.bounds.size.height/2);
    self.rightCenterView.point = CGPointMake(self.bounds.size.width - offset, self.bounds.size.height/2);
    [self setNeedsDisplay];

}

- (void)paddingAllPoions {
    [self resetDefaultPoints: 10];

}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        self.isQuadEffective = ([self checkForNeighbouringPoints] >= 0);
        if (self.isQuadEffective) {
            CGContextSetStrokeColorWithColor(context, self.lineSuccessColor.CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, self.lineFailureColor.CGColor);
        }
        
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, 2.0f);
        
        CGRect boundingRect = CGContextGetClipBoundingBox(context);
        CGContextAddRect(context, boundingRect);
        CGContextFillRect(context, boundingRect);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGPathMoveToPoint(pathRef, NULL, self.bottomLeftView.center.x, self.bottomLeftView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.bottomCenterView.center.x, self.bottomCenterView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.bottomRightView.center.x, self.bottomRightView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.rightCenterView.center.x, self.rightCenterView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.topRightView.center.x, self.topRightView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.topCenterView.center.x, self.topCenterView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.topLeftView.center.x, self.topLeftView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.leftCenterView.center.x, self.leftCenterView.center.y);

        CGPathCloseSubpath(pathRef);
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGPathRelease(pathRef);
    }
}

- (double)checkForNeighbouringPoints {
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    for (LHGOpenCVCropCornerView *cornerView in self.allCornerViews) {
        switch (cornerView.cornerType) {
            case LHGOpenCVCornerTypeTopLeft:{
                p1 = self.topLeftView.point;
                p2 = self.topCenterView.point;
                p3 = self.leftCenterView.point;
                break;
            }
            case LHGOpenCVCornerTypeTopRight:{
                p1 = self.topRightView.point;
                p2 = self.rightCenterView.point;
                p3 = self.topCenterView.point;
                break;
            }
            case LHGOpenCVCornerTypeBottomRight:{
                p1 = self.bottomRightView.point;
                p2 = self.bottomCenterView.point;
                p3 = self.rightCenterView.point;
                break;
            }
            case LHGOpenCVCornerTypeBottomLeft:{
                p1 = self.bottomLeftView.point;
                p2 = self.leftCenterView.point;
                p3 = self.bottomCenterView.point;
                break;
            }
//            case LHGOpenCVCornerTypeTopCenter:{
//                p1 = self.topCenterView.point;
//                p2 = self.topRightView.point;
//                p3 = self.topLeftView.point;
//                break;
//            }
//            case LHGOpenCVCornerTypeBottomCenter:{
//                p1 = self.bottomCenterView.point;
//                p2 = self.bottomLeftView.point;
//                p3 = self.bottomRightView.point;
//                break;
//            }
//            case LHGOpenCVCornerTypeLeftCenter:{
//                p1 = self.leftCenterView.point;
//                p2 = self.topLeftView.point;
//                p3 = self.bottomLeftView.point;
//                break;
//            }
//            case LHGOpenCVCornerTypeRightCenter:{
//                p1 = self.rightCenterView.point;
//                p2 = self.bottomRightView.point;
//                p3 = self.topRightView.point;
//                break;
//            }
            default:{
                break;
            }
        }
        
        CGPoint ab = CGPointMake (p2.x - p1.x, p2.y - p1.y);
        CGPoint cb = CGPointMake( p2.x - p3.x, p2.y - p3.y);
        float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
        float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
        float alpha = atan2(cross, dot);
        
        if ((-1*(float) floor(alpha * 180. / 3.14 + 0.5)) < 0) {
            return -1*(float) floor(alpha * 180. / 3.14 + 0.5);
        }
    }
    return 0;
}

- (void)singlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
//        self.activeCornerView.hidden = NO;
        self.activeCornerView = nil;
    }
    
    CGFloat newX = location.x;
    CGFloat newY = location.y;
    
    //边界处理
    if (newX < self.bounds.origin.x + 10) {
        newX = self.bounds.origin.x + 10;
    } else if (newX > self.frame.size.width - 10) {
        newX = self.frame.size.width - 10;
    }
    if (newY < self.bounds.origin.y + 10) {
        newY = self.bounds.origin.y + 10;
    } else if (newY > self.frame.size.height - 10) {
        newY = self.frame.size.height - 10;
    }
    location = CGPointMake(newX, newY);
    self.activeCornerView.point = location;
    
    
    [self updateCenterPointType:[self point:location]];
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(cropFrameView:didMoveToPoint:state:)]) {
        [self.delegate cropFrameView:self didMoveToPoint:location state:gesture.state];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self];
    for (LHGOpenCVCropCornerView *cornerView in self.allCornerViews) {
        CGPoint covertPoint = [self convertPoint:location toView:cornerView];
        if (CGRectContainsPoint(cornerView.bounds, covertPoint)) {
            self.activeCornerView = cornerView;
//            self.activeCornerView.hidden = YES;
            break;
        }
    }
//    CVLogDebug(@"OpenCV Crop shouldReceiveTouch: %@, cornerView: %@", @(location), self.activeCornerView);
    return YES;
}

#pragma mark - Public

- (void)updatePointValue:(CGPoint)point cornerType:(LHGOpenCVCornerType)cornerType {
    switch (cornerType) {
        case LHGOpenCVCornerTypeTopLeft: {
            self.topLeftView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case LHGOpenCVCornerTypeTopRight: {
            self.topRightView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case LHGOpenCVCornerTypeBottomLeft: {
            self.bottomLeftView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case LHGOpenCVCornerTypeBottomRight: {
            self.bottomRightView.point = point;
            [self setNeedsDisplay];
            break;
        }
        default: {
            break;
        }
    }
}

- (CGPoint)pointValueWithCornerType:(LHGOpenCVCornerType)cornerType {
    switch (cornerType) {
        case LHGOpenCVCornerTypeTopLeft: {
            return self.topLeftView.point;
        }
        case LHGOpenCVCornerTypeTopRight: {
            return self.topRightView.point;
        }
        case LHGOpenCVCornerTypeBottomLeft: {
            return self.bottomLeftView.point;
        }
        case LHGOpenCVCornerTypeBottomRight: {
            return self.bottomRightView.point;
        }
        case LHGOpenCVCornerTypeTopCenter: {
            return self.topCenterView.point;
        }
        case LHGOpenCVCornerTypeBottomCenter: {
            return self.bottomCenterView.point;
        }
        case LHGOpenCVCornerTypeLeftCenter: {
            return self.leftCenterView.point;
        }
        case LHGOpenCVCornerTypeRightCenter: {
            return self.rightCenterView.point;
        }
        default: {
            return self.center;
        }
    }
}

- (LHGOpenCVCornerType)point:(CGPoint)point {
    CGRect pointRect = CGRectMake(point.x, point.y, 1, 1); // 创建一个非常小的矩形
    if (CGRectContainsRect(self.topLeftView.frame, pointRect)) {
        return LHGOpenCVCornerTypeTopLeft;
    } else if (CGRectContainsRect(self.topRightView.frame, pointRect)) {
        return LHGOpenCVCornerTypeTopRight;
    } else if (CGRectContainsRect(self.bottomLeftView.frame, pointRect)) {
        return LHGOpenCVCornerTypeBottomLeft;
    } else if (CGRectContainsRect(self.bottomRightView.frame, pointRect)) {
        return LHGOpenCVCornerTypeBottomRight;
    } else if (CGRectContainsRect(self.topCenterView.frame, pointRect)) {
        return LHGOpenCVCornerTypeTopCenter;
    } else if (CGRectContainsRect(self.bottomCenterView.frame, pointRect)) {
        return LHGOpenCVCornerTypeBottomCenter;
    } else if (CGRectContainsRect(self.leftCenterView.frame, pointRect)) {
        return LHGOpenCVCornerTypeLeftCenter;
    } else if (CGRectContainsRect(self.rightCenterView.frame, pointRect)) {
        return LHGOpenCVCornerTypeRightCenter;
    } else {
        return LHGOpenCVCornerTypeOther;
    }
}

//移动center点位置
- (void)updateCenterPointType:(LHGOpenCVCornerType)cornerType {
    switch (cornerType) {
        case LHGOpenCVCornerTypeTopLeft: {
            self.leftCenterView.point = CGPointMake((self.topLeftView.point.x + self.bottomLeftView.point.x) / 2, (self.topLeftView.point.y + self.bottomLeftView.point.y) / 2);
            self.topCenterView.point = CGPointMake((self.topLeftView.point.x + self.topRightView.point.x) / 2, (self.topLeftView.point.y + self.topRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
        case LHGOpenCVCornerTypeTopRight: {
            self.topCenterView.point = CGPointMake((self.topLeftView.point.x + self.topRightView.point.x) / 2, (self.topLeftView.point.y + self.topRightView.point.y) / 2);
            self.rightCenterView.point = CGPointMake((self.topRightView.point.x + self.bottomRightView.point.x) / 2, (self.topRightView.point.y + self.bottomRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
        case LHGOpenCVCornerTypeBottomLeft: {
            self.leftCenterView.point = CGPointMake((self.topLeftView.point.x + self.bottomLeftView.point.x) / 2, (self.topLeftView.point.y + self.bottomLeftView.point.y) / 2);
            self.bottomCenterView.point = CGPointMake((self.bottomLeftView.point.x + self.bottomRightView.point.x) / 2, (self.bottomLeftView.point.y + self.bottomRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
        case LHGOpenCVCornerTypeBottomRight: {
            self.rightCenterView.point = CGPointMake((self.topRightView.point.x + self.bottomRightView.point.x) / 2, (self.topRightView.point.y + self.bottomRightView.point.y) / 2);
            self.bottomCenterView.point = CGPointMake((self.bottomLeftView.point.x + self.bottomRightView.point.x) / 2, (self.bottomLeftView.point.y + self.bottomRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
            //todo
//        case LHGOpenCVCornerTypeTopCenter: {
//            
//        }
//        case LHGOpenCVCornerTypeBottomCenter: {
//            
//        }
//        case LHGOpenCVCornerTypeLeftCenter: {
//            
//        }
//        case LHGOpenCVCornerTypeRightCenter: {
//            
//        }
        default: {
            break;
        }
    }
}


- (UIImage *)exportEditPhoto:(UIImageView *)imageView {
    CGFloat scale = [imageView shm_contentScale];
    CGSize targetSize = CGSizeMake(imageView.image.size.width, imageView.image.size.height);

    CGPoint topLeftPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeTopLeft];
    CGPoint topRightPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeTopRight];
    CGPoint bottomLeftPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeBottomLeft];
    CGPoint bottomRightPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeBottomRight];
    CGPoint topCenterPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeTopCenter];
    CGPoint bottomCenterPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeBottomCenter];
    CGPoint leftCenterPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeLeftCenter];
    CGPoint rightCenterPoint = [self pointValueWithCornerType:LHGOpenCVCornerTypeRightCenter];

    topLeftPoint.x /= scale;
    topLeftPoint.y /= scale;
    topRightPoint.x /= scale;
    topRightPoint.y /= scale;
    bottomLeftPoint.x /= scale;
    bottomLeftPoint.y /= scale;
    bottomRightPoint.x /= scale;
    bottomRightPoint.y /= scale;
    
    topCenterPoint.x /= scale;
    topCenterPoint.y /= scale;
    bottomCenterPoint.x /= scale;
    bottomCenterPoint.y /= scale;
    leftCenterPoint.x /= scale;
    leftCenterPoint.y /= scale;
    rightCenterPoint.x /= scale;
    rightCenterPoint.y /= scale;
    // 创建一个图形上下文
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 定义裁剪区域的路径
    UIBezierPath *clipPath = [UIBezierPath bezierPath];
    [clipPath moveToPoint:bottomLeftPoint];
    [clipPath addLineToPoint:bottomCenterPoint];
    [clipPath addLineToPoint:bottomRightPoint];
    [clipPath addLineToPoint:rightCenterPoint];
    [clipPath addLineToPoint:topRightPoint];
    [clipPath addLineToPoint:topCenterPoint];
    [clipPath addLineToPoint:topLeftPoint];
    [clipPath addLineToPoint:leftCenterPoint];

    [clipPath closePath];
    // 将裁剪路径添加为上下文的裁剪区域
    [clipPath addClip];
    // 在图形上下文中绘制原始图像
    [imageView.image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    // 获取裁剪后的图像
    UIImage *clippedImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束图像上下文
    UIGraphicsEndImageContext();
    return clippedImage;
}


#pragma mark - Setters

- (void)setlineSuccessColor:(UIColor *)lineSuccessColor {
    _lineSuccessColor = lineSuccessColor;
    self.topLeftView.layer.borderColor = lineSuccessColor.CGColor;
    self.topRightView.layer.borderColor = lineSuccessColor.CGColor;
    self.bottomLeftView.layer.borderColor = lineSuccessColor.CGColor;
    self.bottomRightView.layer.borderColor = lineSuccessColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setCornerFillColor:(UIColor *)cornerFillColor {
    _cornerFillColor = cornerFillColor;
    self.topLeftView.layer.backgroundColor = cornerFillColor.CGColor;
    self.topRightView.layer.backgroundColor = cornerFillColor.CGColor;
    self.bottomLeftView.layer.backgroundColor = cornerFillColor.CGColor;
    self.bottomRightView.layer.backgroundColor = cornerFillColor.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - Getters

- (LHGOpenCVCropCornerView *)topLeftView {
    if (!_topLeftView) {
        _topLeftView = [self cornerView];
        _topLeftView.cornerType = LHGOpenCVCornerTypeTopLeft;
    }
    return _topLeftView;
}

- (LHGOpenCVCropCornerView *)topRightView {
    if (!_topRightView) {
        _topRightView = [self cornerView];
        _topRightView.cornerType = LHGOpenCVCornerTypeTopRight;
    }
    return _topRightView;
}

- (LHGOpenCVCropCornerView *)bottomLeftView {
    if (!_bottomLeftView) {
        _bottomLeftView = [self cornerView];
        _bottomLeftView.cornerType = LHGOpenCVCornerTypeBottomLeft;
    }
    return _bottomLeftView;
}

- (LHGOpenCVCropCornerView *)bottomRightView {
    if (!_bottomRightView) {
        _bottomRightView = [self cornerView];
        _bottomRightView.cornerType = LHGOpenCVCornerTypeBottomRight;
    }
    return _bottomRightView;
}

- (LHGOpenCVCropCornerView *)topCenterView {
    if (!_topCenterView) {
        _topCenterView = [self cornerView];
        _topCenterView.cornerType = LHGOpenCVCornerTypeTopCenter;
    }
    return _topCenterView;
}

- (LHGOpenCVCropCornerView *)bottomCenterView {
    if (!_bottomCenterView) {
        _bottomCenterView = [self cornerView];
        _bottomCenterView.cornerType = LHGOpenCVCornerTypeBottomCenter;
    }
    return _bottomCenterView;
}

- (LHGOpenCVCropCornerView *)leftCenterView {
    if (!_leftCenterView) {
        _leftCenterView = [self cornerView];
        _leftCenterView.cornerType = LHGOpenCVCornerTypeLeftCenter;
    }
    return _leftCenterView;
}

- (LHGOpenCVCropCornerView *)rightCenterView {
    if (!_rightCenterView) {
        _rightCenterView = [self cornerView];
        _rightCenterView.cornerType = LHGOpenCVCornerTypeRightCenter;
    }
    return _rightCenterView;
}

- (LHGOpenCVCropCornerView *)cornerView {
    LHGOpenCVCropCornerView *cornerView = [[LHGOpenCVCropCornerView alloc] init];
    cornerView.frame = CGRectMake(0, 0, kCropButtonSize, kCropButtonSize);
//    cornerView.alpha = 0.5;
    cornerView.layer.backgroundColor = self.cornerFillColor.CGColor;
    cornerView.layer.cornerRadius = kCropButtonSize/2;
    cornerView.layer.borderWidth = 1.0;
    cornerView.layer.borderColor = self.lineSuccessColor.CGColor;
    cornerView.layer.masksToBounds = YES;
    return cornerView;
}

- (NSArray<UIView *> *)allCornerViews {
    if (!_allCornerViews) {
        _allCornerViews = @[self.topLeftView, self.topRightView, self.bottomRightView, self.bottomLeftView, self.topCenterView, self.bottomCenterView, self.leftCenterView, self.rightCenterView];
    }
    return _allCornerViews;
}

- (UIColor *)cornerFillColor {
    if (!_cornerFillColor) {
        _cornerFillColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _cornerFillColor;
}

- (UIColor *)lineSuccessColor {
    if (!_lineSuccessColor) {
        _lineSuccessColor = [UIColor whiteColor];
    }
    return _lineSuccessColor;
}

- (UIColor *)lineFailureColor {
    if (!_lineFailureColor) {
        _lineFailureColor = [UIColor redColor];
    }
    return _lineFailureColor;
}

@end
