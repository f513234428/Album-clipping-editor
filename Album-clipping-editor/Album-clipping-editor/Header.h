//
//  Header.h
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#ifndef Header_h
#define Header_h


#define KWIDTH [UIScreen mainScreen].bounds.size.width
#define KHEIGHT [UIScreen mainScreen].bounds.size.height
#define KBadgeColor [UIColor colorWithRed:255/255.0 green:71/255.0 blue:19/255.0 alpha:1]



#ifndef weakify
#if DEBUG
    #if __has_feature(objc_arc)
    #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
    #else
    #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
    #endif
#else
    #if __has_feature(objc_arc)
    #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
    #else
    #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
    #endif
#endif
#endif

#ifndef strongify
        #if DEBUG
            #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
            #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
            #endif
        #else
            #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
            #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
            #endif
        #endif
    #endif

//statusbar的高度
#define STATUS_HEIGHT \
({\
    CGFloat height = 0.0;\
    if (@available(iOS 13.0, *)) {\
        CGFloat topHeight = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.top;\
        height = topHeight ? topHeight : 20.0;\
    }else {\
        height = [[UIApplication sharedApplication] statusBarFrame].size.height;\
    }\
    (height);\
})\

//底部安全高度
#define BOTTOM_HEIGHT \
({\
    CGFloat height = 0.0;\
    if (@available(iOS 13.0, *)) {\
        NSSet *set = [UIApplication sharedApplication].connectedScenes;\
        UIWindowScene *windowScene = [set anyObject];\
        UIWindow *window = windowScene.windows.firstObject;\
        height = window.safeAreaInsets.bottom;\
    } else if (@available(iOS 11.0, *)) {\
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;\
        height = window.safeAreaInsets.bottom;\
    }\
    (height);\
})\

#endif /* Header_h */
