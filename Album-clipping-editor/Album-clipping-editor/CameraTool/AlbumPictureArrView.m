//
//  AlbumPictureArrView.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/26.
//

#import "AlbumPictureArrView.h"
#import <Masonry.h>

@interface AlbumPictureArrView ()
@property(nonatomic, strong) UIView *labelBGView;
@property(nonatomic, strong) NSMutableDictionary *blockActionDict;

@end

@implementation AlbumPictureArrView

-(instancetype)init{
    if (self = [super initWithFrame:CGRectZero]) {
        [self initSubView];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    [self.photoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(48);
    }];
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(48);
        make.top.mas_equalTo(self).mas_offset(1);
    }];
    [self.labelBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(43);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
    [self.photoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.photoBGView.mas_bottom).mas_offset(5);
        make.center.mas_equalTo(self.labelBGView);
        make.width.mas_equalTo(self);
    }];
}

- (void)setPhotoStyle {
    self.labelBGView.hidden = YES;
    self.photoView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.photoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.photoBGView.mas_bottom).mas_offset(5);
        make.width.mas_equalTo(self);
    }];
}

- (UIViewController *)viewController {
    //通过响应者链，取得此视图所在的视图控制器
    UIResponder *next = self.nextResponder;
    do {
        //判断响应者对象是否是视图控制器类型
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    }while(next != nil);
    return nil;
}

/**
 给View添加点击事件

 @param block 事件传递
 */
- (void)tapActionGesture:(actionBlock)block{
    [self addBlock:block];
    [self whenTouchOne];
}

-(void)addBlock:(actionBlock)block{
    if (self.blockActionDict == nil){
        self.blockActionDict = [[NSMutableDictionary alloc]init];
    }
    NSLog(@"%lu",(unsigned long)self.hash);
    self.blockActionDict[[NSString stringWithFormat:@"%lu",(unsigned long)self.hash]] = block;
}

-(void)whenTouchOne{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGesture];
}

-(void)tapAction{
    NSLog(@"%lu",(unsigned long)self.hash);
   actionBlock block = self.blockActionDict[[NSString stringWithFormat:@"%lu",(unsigned long)self.hash]];
    block();
}

- (UIView *)photoBGView {
    if (!_photoBGView) {
        _photoBGView = [[UIView alloc] init];
        [self addSubview:_photoBGView];
    }
    return _photoBGView;
}
- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.layer.masksToBounds = YES;
        // 设置圆角大小
        _photoView.layer.cornerRadius = 5.0 ;
        // 设置控件边框的宽度
        _photoView.layer.borderWidth = 1.0;
        // 设置控件边框的颜色
        _photoView.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:71/255.0 blue:19/255.0 alpha:1] CGColor];
        [_photoBGView addSubview:_photoView];
    }
    return _photoView;
}
- (UILabel *)photoLabel {
    if (!_photoLabel) {
        _photoLabel = [[UILabel alloc] init];
        _photoLabel.text = @"Done";
        _photoLabel.textAlignment = NSTextAlignmentCenter;
        _photoLabel.textColor = [UIColor whiteColor];
        _photoLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_photoLabel];
    }
    return _photoLabel;
}
- (UIView *)labelBGView {
    if (!_labelBGView) {
        _labelBGView = [[UIView alloc] init];
        _labelBGView.layer.masksToBounds = YES;
        _labelBGView.layer.cornerRadius = 10.0 ;
        _labelBGView.backgroundColor = [UIColor colorWithRed:255/255.0 green:71/255.0 blue:19/255.0 alpha:1];

        [self addSubview:_labelBGView];
    }
    return _labelBGView;
}
@end
