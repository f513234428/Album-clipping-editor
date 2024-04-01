//
//  ViewController.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import "ViewController.h"
#import "CameraTool/CameraViewController.h"
#import <JSBadgeView.h>
#import "TestViewController.h"

#define kNumBadges 100


#define kSquareSideLength 64.0f
#define kSquareCornerRadius 10.0f
#define kMarginBetweenSquares 10.0f
#define kSquareColor [UIColor colorWithRed:0.004 green:0.349 blue:0.616 alpha:1]

@interface ViewController ()<CameraDelegate>
@property(nonatomic, strong) CameraViewController *cameraViewvController;
@property(nonatomic, strong) JSBadgeView *badgeView;
@property(nonatomic, assign) int tag;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *testBtn = [[UIButton alloc] init];
    testBtn.frame = CGRectMake(100, 100, 100, 100);
    [testBtn setTitle:@"开始拍照" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    testBtn.center = self.view.center;
    [testBtn addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
//    UIButton *test2Btn = [[UIButton alloc] init];
//    test2Btn.frame = CGRectMake(self.view.frame.size.width/2 - 50, 400, 100, 100);
//    [test2Btn setTitle:@"索引增加" forState:UIControlStateNormal];
//    [test2Btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
//    [test2Btn addTarget:self action:@selector(changeBadge) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:test2Btn];
//    
//    UIButton *test4Btn = [[UIButton alloc] init];
//    test4Btn.frame = CGRectMake(self.view.frame.size.width/2 - 50, 600, 100, 100);
//    [test4Btn setTitle:@"测试跳转" forState:UIControlStateNormal];
//    [test4Btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
//    [test4Btn addTarget:self action:@selector(testChange) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:test4Btn];

    _tag = 1;
    
//    CGRect rectangleBounds = CGRectMake(0.0f,
//                                        0.0f,
//                                        kSquareSideLength,
//                                        kSquareSideLength);
//
//    
//    UIButton *test3Btn = [[UIButton alloc] init];
//    test3Btn.frame = CGRectIntegral(CGRectMake(100, 200, 100, 100));
//    test3Btn.backgroundColor = [UIColor yellowColor];
//    self.badgeView = [[JSBadgeView alloc] initWithParentView:test3Btn alignment:JSBadgeViewAlignmentTopRight];
//    self.badgeView.badgeText = [NSString stringWithFormat:@"%d",_tag];
//    [self.view addSubview:test3Btn];
}

- (void)changeBadge {
    _tag ++;
    self.badgeView.badgeText = [NSString stringWithFormat:@"%d",_tag];

}

- (void)testChange {
    TestViewController *vc = [[TestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)cameraAction
{
    self.cameraViewvController = [[CameraViewController alloc] init];
    self.cameraViewvController.delegate = self;
//    self.cameraViewvController.modalPresentationStyle = 0;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self.cameraViewvController];
    navi.modalPresentationStyle = 0;
    //self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self presentViewController:navi animated:YES completion:nil];
    
    
}
//选取照片的回调
- (void)CameraTakePhoto:(UIImage *)image
{
    NSLog(@"-----%@",image);
}


@end
