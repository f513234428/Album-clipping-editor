//
//  LHGOpenCVPhotoHelper.h
//  Album-clipping-editor
//
//  Created by syz on 2024/4/1.
//

#import <Foundation/Foundation.h>
#import "HXPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LHGOpenCVPhotoHelper : NSObject
+ (instancetype)sharedHelper;
- (void)removePhotoArrIndex:(NSInteger)index ;
- (NSMutableArray *)getEditPhotoArr ;
- (void)savePhoto:(HXPhotoModel *)photo ;

- (void)setCurrentPhotoCanSave:(Boolean)canSave ;
- (bool)isCanSavePhoto ;
@end

NS_ASSUME_NONNULL_END
