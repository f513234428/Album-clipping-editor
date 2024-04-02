//
//  A4AlbumDefaultView.h
//  Album-clipping-editor
//
//  Created by syz on 2024/4/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^actionBlock)(void);

@interface A4AlbumDefaultView : UIView
@property(nonatomic, strong) UIImageView *photoView;
- (void)tapActionGesture:(actionBlock)block;
- (UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
