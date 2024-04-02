//
//  A4AlbumDefaultView.m
//  Album-clipping-editor
//
//  Created by syz on 2024/4/1.
//

#import "A4AlbumDefaultView.h"
#import <Masonry.h>

@interface A4AlbumDefaultView ()
@property(nonatomic, strong) UIImageView *bottomView;
@property(nonatomic, strong) NSMutableDictionary *blockActionDict;

@end

@implementation A4AlbumDefaultView
- (instancetype)init
{
    self = [super init];
    if (self) {
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
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(32);
    }];
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(24);
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

- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        [self addSubview:_photoView];

    }
    return _photoView;
}

- (UIImageView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIImageView alloc] init];
        _bottomView.image = [UIImage imageNamed:@"blackBottom"];
        [self addSubview:_bottomView];
    }
    return _bottomView;
}

@end
