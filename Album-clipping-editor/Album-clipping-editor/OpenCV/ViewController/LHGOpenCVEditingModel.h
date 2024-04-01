//
//  LHGOpenCVEditingModel.h
//  Album-clipping-editor
//
//  Created by syz on 2024/3/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHGOpenCVEditingModel : NSObject
@property(nonatomic, strong) NSMutableArray *editPointArr;
@property(nonatomic, strong) UIImage *originImage;
@property(nonatomic, assign) int editTag;
@end

NS_ASSUME_NONNULL_END
