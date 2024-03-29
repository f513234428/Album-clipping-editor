//
//  AlbumPictureArrView.h
//  Album-clipping-editor
//
//  Created by syz on 2024/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^actionBlock)(void);

@interface AlbumPictureArrView : UIView
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) UIView *photoBGView;
@property(nonatomic, strong) UILabel *photoLabel;

- (UIViewController *)viewController;
- (void)tapActionGesture:(actionBlock)block;
- (void)setPhotoStyle;

@end

NS_ASSUME_NONNULL_END
