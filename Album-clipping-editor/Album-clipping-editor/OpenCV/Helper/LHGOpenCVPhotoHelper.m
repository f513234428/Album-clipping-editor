//
//  LHGOpenCVPhotoHelper.m
//  Album-clipping-editor
//
//  Created by syz on 2024/4/1.
//

#import "LHGOpenCVPhotoHelper.h"

@interface LHGOpenCVPhotoHelper ()
@property(nonatomic, strong) NSMutableArray *photoArr;
@property(nonatomic, assign) bool canSavePhoto;
@end


@implementation LHGOpenCVPhotoHelper
+ (instancetype)sharedHelper {
    static dispatch_once_t onceToken;
    static LHGOpenCVPhotoHelper *sharedHelper = nil;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
        sharedHelper.photoArr = [NSMutableArray array];
        sharedHelper.canSavePhoto = YES;
    });
    
    return sharedHelper;
}

- (void)savePhoto:(HXPhotoModel *)photo {
    if (![self.photoArr containsObject: photo]) {
        [self.photoArr addObject:photo];
    }
}

- (NSMutableArray *)getEditPhotoArr {
    return self.photoArr;
}

- (void)removePhotoArrIndex:(NSInteger)index {
    if (self.photoArr.count > index) {
        [self.photoArr removeObjectAtIndex:index];
    }
}

- (void)setCurrentPhotoCanSave:(Boolean)canSave {
    self.canSavePhoto = canSave;
}

- (bool)isCanSavePhoto {
    return self.canSavePhoto;
}

@end
