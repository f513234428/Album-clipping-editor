//
//  ReLayoutButton.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import "ReLayoutButton.h"
#import <QuartzCore/QuartzCore.h>

@interface ReLayoutButton ()
@property(nonatomic, strong) UIColor *defaultBorderColor;
@property(nonatomic, strong) UIView *textView;
@property(nonatomic, strong) UILabel *textLabel;
@end

@implementation ReLayoutButton

-(instancetype)init:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    self.backgroundColor = [UIColor clearColor];
    self.defaultBorderColor = [UIColor whiteColor];
    self.center = self.center;
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

//描边
- (void)showBoundingBox {
//    self.layer.masksToBounds = YES;
    self.contentMode = UIViewContentModeScaleToFill;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.imageView.layer.masksToBounds = YES;
    
    // 设置圆角大小
    self.imageView.layer.cornerRadius = 5.0 ;
    // 设置控件边框的宽度
    self.imageView.layer.borderWidth = 1.0;
    // 设置控件边框的颜色
    self.imageView.layer.borderColor = [self.defaultBorderColor CGColor];
//    [self setFont:[UIFont systemFontOfSize:10]];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
}

- (void)addTextView {
    self.imageView.layer.masksToBounds = NO;

    self.textView.frame = CGRectMake(0, self.frame.size.height-25, self.frame.size.width, 20);
    self.textLabel.text = @"Done";
    self.textLabel.frame = self.textView.frame;
//    self.imageView.layer.cornerRadius = 5.0 ;

    
    
}

- (void)setBorderColor: (UIColor *)color {
    self.defaultBorderColor = color;
    self.imageView.layer.borderColor = [color CGColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];


    if (self.imageView.image == nil || self.titleLabel.text.length == 0) {
        return;
    }

    // 水平调整后
    if (self.titleLabel.center.y == self.imageView.center.y && self.titleLabel.frame.origin.x < self.imageView.frame.origin.x) {
        return;
    }
    
    // 垂直调整后
    if (self.titleLabel.center.x == self.imageView.center.x) {
        return;
    }
    
    
    [self.titleLabel sizeToFit];
    [self.imageView sizeToFit];
    
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    
    CGFloat margin = self.margin;
    
    CGSize buttonSize = self.bounds.size;
    
    //计算字体的大小，如果titleLabel的宽度小于字体的宽度，则是没显示全，给label宽度赋值
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleFrame.size.width < frameSize.width) {
        titleFrame.size.width = frameSize.width;
     }
    
    switch (self.layoutType) {
        case RelayoutTypeNone:
            
            return;
            break;
        case RelayoutTypeUpDown:
        {
            
            
            margin = margin ? :8;
            CGFloat height = titleFrame.size.height + imageFrame.size.height + margin;
            
            CGFloat imageCenterY = (buttonSize.height - height) * 0.5 + imageFrame.size.height * 0.5;
            self.imageView.center = CGPointMake(buttonSize.width * 0.5, imageCenterY);
            
            CGFloat titleCenterY = CGRectGetMaxY(self.imageView.frame) + margin + titleFrame.size.height * 0.5;
            self.titleLabel.center = CGPointMake(buttonSize.width * 0.5, titleCenterY);
        }
            break;
        case RelayoutTypeRightLeft:
        {
            margin = margin ? :5;
            CGFloat totalWidth = titleFrame.size.width + imageFrame.size.width + margin;
            CGFloat titleCenterX = (buttonSize.width - totalWidth) * 0.5 + titleFrame.size.width * 0.5;
            self.titleLabel.center = CGPointMake(titleCenterX, buttonSize.height * 0.5);

            
            CGFloat imageCenterX = CGRectGetMaxX(self.titleLabel.frame) + margin + imageFrame.size.width * 0.5;
            
            self.imageView.center = CGPointMake(imageCenterX, buttonSize.height * 0.5);

        }
            break;
        default:
            break;
    }
}

- (UIView *)textView {
    if (!_textView) {
        _textView = [[UIView alloc] init];
        _textView.backgroundColor = self.defaultBorderColor;
        _textView.layer.cornerRadius = 10;
        [self addSubview:_textView];
        [self sendSubviewToBack:_textView];
        [self sendSubviewToBack:self.imageView];
    }
    return _textView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

@end
