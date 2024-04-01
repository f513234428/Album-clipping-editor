//
//  A4CropFrameView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "A4CropFrameView.h"
#import "A4CropCornerView.h"
#import "UIImageView+LHGContentRect.h"

#define kCropButtonSize 20
#define kCropButtonMargin 40

@interface A4CropFrameView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) A4CropCornerView *topLeftView;
@property (nonatomic, strong, readwrite) A4CropCornerView *topRightView;
@property (nonatomic, strong, readwrite) A4CropCornerView *bottomLeftView;
@property (nonatomic, strong, readwrite) A4CropCornerView *bottomRightView;
@property (nonatomic, weak) A4CropCornerView *activeCornerView;
@property (nonatomic, copy) NSArray <UIView*> *allCornerViews;

@property (nonatomic, strong) A4CropCornerView *topCenterView;
@property (nonatomic, strong) A4CropCornerView *bottomCenterView;
@property (nonatomic, strong) A4CropCornerView *leftCenterView;
@property (nonatomic, strong) A4CropCornerView *rightCenterView;

@property(nonatomic, strong) NSMutableArray *originalPositions;//坐标保存数组
@end

@implementation A4CropFrameView
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
    for (A4CropCornerView *cornerView in self.allCornerViews) {
        switch (cornerView.cornerType) {
            case A4CornerTypeTopLeft:{
                p1 = self.topLeftView.point;
                p2 = self.topCenterView.point;
                p3 = self.leftCenterView.point;
                break;
            }
            case A4CornerTypeTopRight:{
                p1 = self.topRightView.point;
                p2 = self.rightCenterView.point;
                p3 = self.topCenterView.point;
                break;
            }
            case A4CornerTypeBottomRight:{
                p1 = self.bottomRightView.point;
                p2 = self.bottomCenterView.point;
                p3 = self.rightCenterView.point;
                break;
            }
            case A4CornerTypeBottomLeft:{
                p1 = self.bottomLeftView.point;
                p2 = self.leftCenterView.point;
                p3 = self.bottomCenterView.point;
                break;
            }
//            case A4CornerTypeTopCenter:{
//                p1 = self.topCenterView.point;
//                p2 = self.topRightView.point;
//                p3 = self.topLeftView.point;
//                break;
//            }
//            case A4CornerTypeBottomCenter:{
//                p1 = self.bottomCenterView.point;
//                p2 = self.bottomLeftView.point;
//                p3 = self.bottomRightView.point;
//                break;
//            }
//            case A4CornerTypeLeftCenter:{
//                p1 = self.leftCenterView.point;
//                p2 = self.topLeftView.point;
//                p3 = self.bottomLeftView.point;
//                break;
//            }
//            case A4CornerTypeRightCenter:{
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
    for (A4CropCornerView *cornerView in self.allCornerViews) {
        CGPoint covertPoint = [self convertPoint:location toView:cornerView];
        if (CGRectContainsPoint(cornerView.bounds, covertPoint)) {
            self.activeCornerView = cornerView;
            break;
        }
    }
    return YES;
}

#pragma mark - Public

- (void)updatePointValue:(CGPoint)point cornerType:(A4CornerType)cornerType {
    switch (cornerType) {
        case A4CornerTypeTopLeft: {
            self.topLeftView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case A4CornerTypeTopRight: {
            self.topRightView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case A4CornerTypeBottomLeft: {
            self.bottomLeftView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case A4CornerTypeBottomRight: {
            self.bottomRightView.point = point;
            [self setNeedsDisplay];
            break;
        }
        default: {
            break;
        }
    }
}

- (CGPoint)pointValueWithCornerType:(A4CornerType)cornerType {
    switch (cornerType) {
        case A4CornerTypeTopLeft: {
            return self.topLeftView.point;
        }
        case A4CornerTypeTopRight: {
            return self.topRightView.point;
        }
        case A4CornerTypeBottomLeft: {
            return self.bottomLeftView.point;
        }
        case A4CornerTypeBottomRight: {
            return self.bottomRightView.point;
        }
        case A4CornerTypeTopCenter: {
            return self.topCenterView.point;
        }
        case A4CornerTypeBottomCenter: {
            return self.bottomCenterView.point;
        }
        case A4CornerTypeLeftCenter: {
            return self.leftCenterView.point;
        }
        case A4CornerTypeRightCenter: {
            return self.rightCenterView.point;
        }
        default: {
            return self.center;
        }
    }
}

- (A4CornerType)point:(CGPoint)point {
//    CGRect pointRect = CGRectMake(point.x, point.y, 1, 1); // 创建一个非常小的矩形
    CGRect pointRect = CGRectMake(point.x - 20, point.y - 20, 40, 40); // 创建一个大的矩形

    if (CGRectContainsRect(self.topLeftView.frame, pointRect)) {
        return A4CornerTypeTopLeft;
    } else if (CGRectContainsRect(self.topRightView.frame, pointRect)) {
        return A4CornerTypeTopRight;
    } else if (CGRectContainsRect(self.bottomLeftView.frame, pointRect)) {
        return A4CornerTypeBottomLeft;
    } else if (CGRectContainsRect(self.bottomRightView.frame, pointRect)) {
        return A4CornerTypeBottomRight;
    } else if (CGRectContainsRect(self.topCenterView.frame, pointRect)) {
        return A4CornerTypeTopCenter;
    } else if (CGRectContainsRect(self.bottomCenterView.frame, pointRect)) {
        return A4CornerTypeBottomCenter;
    } else if (CGRectContainsRect(self.leftCenterView.frame, pointRect)) {
        return A4CornerTypeLeftCenter;
    } else if (CGRectContainsRect(self.rightCenterView.frame, pointRect)) {
        return A4CornerTypeRightCenter;
    } else {
        return A4CornerTypeOther;
    }
}

//移动center点位置
- (void)updateCenterPointType:(A4CornerType)cornerType {
    switch (cornerType) {
        case A4CornerTypeTopLeft: {
            self.leftCenterView.point = CGPointMake((self.topLeftView.point.x + self.bottomLeftView.point.x) / 2, (self.topLeftView.point.y + self.bottomLeftView.point.y) / 2);
            self.topCenterView.point = CGPointMake((self.topLeftView.point.x + self.topRightView.point.x) / 2, (self.topLeftView.point.y + self.topRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
        case A4CornerTypeTopRight: {
            self.topCenterView.point = CGPointMake((self.topLeftView.point.x + self.topRightView.point.x) / 2, (self.topLeftView.point.y + self.topRightView.point.y) / 2);
            self.rightCenterView.point = CGPointMake((self.topRightView.point.x + self.bottomRightView.point.x) / 2, (self.topRightView.point.y + self.bottomRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
        case A4CornerTypeBottomLeft: {
            self.leftCenterView.point = CGPointMake((self.topLeftView.point.x + self.bottomLeftView.point.x) / 2, (self.topLeftView.point.y + self.bottomLeftView.point.y) / 2);
            self.bottomCenterView.point = CGPointMake((self.bottomLeftView.point.x + self.bottomRightView.point.x) / 2, (self.bottomLeftView.point.y + self.bottomRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
        case A4CornerTypeBottomRight: {
            self.rightCenterView.point = CGPointMake((self.topRightView.point.x + self.bottomRightView.point.x) / 2, (self.topRightView.point.y + self.bottomRightView.point.y) / 2);
            self.bottomCenterView.point = CGPointMake((self.bottomLeftView.point.x + self.bottomRightView.point.x) / 2, (self.bottomLeftView.point.y + self.bottomRightView.point.y) / 2);
            [self setNeedsDisplay];
        }
            //todo
//        case A4CornerTypeTopCenter: {
//            
//        }
//        case A4CornerTypeBottomCenter: {
//            
//        }
//        case A4CornerTypeLeftCenter: {
//            
//        }
//        case A4CornerTypeRightCenter: {
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

    CGPoint topLeftPoint = [self pointValueWithCornerType:A4CornerTypeTopLeft];
    CGPoint topRightPoint = [self pointValueWithCornerType:A4CornerTypeTopRight];
    CGPoint bottomLeftPoint = [self pointValueWithCornerType:A4CornerTypeBottomLeft];
    CGPoint bottomRightPoint = [self pointValueWithCornerType:A4CornerTypeBottomRight];
    CGPoint topCenterPoint = [self pointValueWithCornerType:A4CornerTypeTopCenter];
    CGPoint bottomCenterPoint = [self pointValueWithCornerType:A4CornerTypeBottomCenter];
    CGPoint leftCenterPoint = [self pointValueWithCornerType:A4CornerTypeLeftCenter];
    CGPoint rightCenterPoint = [self pointValueWithCornerType:A4CornerTypeRightCenter];

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
//    CGContextRef context = UIGraphicsGetCurrentContext();
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

- (A4CropCornerView *)topLeftView {
    if (!_topLeftView) {
        _topLeftView = [self cornerView];
        _topLeftView.cornerType = A4CornerTypeTopLeft;
    }
    return _topLeftView;
}

- (A4CropCornerView *)topRightView {
    if (!_topRightView) {
        _topRightView = [self cornerView];
        _topRightView.cornerType = A4CornerTypeTopRight;
    }
    return _topRightView;
}

- (A4CropCornerView *)bottomLeftView {
    if (!_bottomLeftView) {
        _bottomLeftView = [self cornerView];
        _bottomLeftView.cornerType = A4CornerTypeBottomLeft;
    }
    return _bottomLeftView;
}

- (A4CropCornerView *)bottomRightView {
    if (!_bottomRightView) {
        _bottomRightView = [self cornerView];
        _bottomRightView.cornerType = A4CornerTypeBottomRight;
    }
    return _bottomRightView;
}

- (A4CropCornerView *)topCenterView {
    if (!_topCenterView) {
        _topCenterView = [self cornerView];
        _topCenterView.cornerType = A4CornerTypeTopCenter;
    }
    return _topCenterView;
}

- (A4CropCornerView *)bottomCenterView {
    if (!_bottomCenterView) {
        _bottomCenterView = [self cornerView];
        _bottomCenterView.cornerType = A4CornerTypeBottomCenter;
    }
    return _bottomCenterView;
}

- (A4CropCornerView *)leftCenterView {
    if (!_leftCenterView) {
        _leftCenterView = [self cornerView];
        _leftCenterView.cornerType = A4CornerTypeLeftCenter;
    }
    return _leftCenterView;
}

- (A4CropCornerView *)rightCenterView {
    if (!_rightCenterView) {
        _rightCenterView = [self cornerView];
        _rightCenterView.cornerType = A4CornerTypeRightCenter;
    }
    return _rightCenterView;
}

- (A4CropCornerView *)cornerView {
    A4CropCornerView *cornerView = [[A4CropCornerView alloc] init];
    cornerView.frame = CGRectMake(0, 0, kCropButtonSize, kCropButtonSize);
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
