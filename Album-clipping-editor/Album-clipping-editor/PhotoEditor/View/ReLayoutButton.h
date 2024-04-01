//
//  ReLayoutButton.h
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,RelayoutType) {
    /// 系统默认样式
    RelayoutTypeNone = 0,
    /// 上图下文
    RelayoutTypeUpDown = 1,
    /// 左文右图
    RelayoutTypeRightLeft = 2,
};

@interface ReLayoutButton : UIButton

/** 布局样式*/
@property (assign,nonatomic) IBInspectable NSInteger  layoutType;
@property (assign,nonatomic) IBInspectable CGFloat  margin;
//描边
- (void)showBoundingBox;
- (void)setBorderColor: (UIColor *)color;
- (void)addTextView;
@end

NS_ASSUME_NONNULL_END
