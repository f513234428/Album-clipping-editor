//
//  ViewController.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import "ViewController.h"
#import "CameraTool/CameraViewController.h"

@interface ViewController ()<CameraDelegate>
@property(nonatomic, strong) CameraViewController *cameraViewvController;

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
}

- (void)cameraAction
{
    self.cameraViewvController = [[CameraViewController alloc] init];
    self.cameraViewvController.delegate = self;
    self.cameraViewvController.modalPresentationStyle = 0;
    
    //self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self presentViewController:self.cameraViewvController animated:YES completion:nil];
    
    
}
//选取照片的回调
- (void)CameraTakePhoto:(UIImage *)image
{
    NSLog(@"-----%@",image);
}


@end
