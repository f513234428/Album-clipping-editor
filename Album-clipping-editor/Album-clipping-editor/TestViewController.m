//
//  TestViewController.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/29.
//

#import "TestViewController.h"
#import "ShowPictureController.h"

@interface TestViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化ScrollView
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0);
        [self.view addSubview:self.scrollView];
    NSMutableArray *imageArr = [NSMutableArray array];
    [imageArr addObject:[UIImage imageNamed:@"doneBtn"]];
    [imageArr addObject:[UIImage imageNamed:@"nextBtn"]];
    [imageArr addObject:[UIImage imageNamed:@"previousBtnT"]];

        // 假设你有3个ViewController需要分页显示
        NSUInteger numberOfViewControllers = 3;
        CGFloat scrollViewWidth = self.scrollView.frame.size.width;
        for (int i = 0; i < numberOfViewControllers; i++) {
            // 创建新的ViewController
            ShowPictureController *contentViewController = [[ShowPictureController alloc] init];
            contentViewController.showImage = imageArr[i];
            // 设置每个ViewController的frame
            contentViewController.view.frame = CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, self.scrollView.frame.size.height);
            
            // 添加到ScrollView中
            [self.scrollView addSubview:contentViewController.view];
            
            // 如果使用UIViewController的方式，记得将其添加为子控制器
            [self addChildViewController:contentViewController];
        }
        
        // 设置contentSize
        self.scrollView.contentSize = CGSizeMake(scrollViewWidth * numberOfViewControllers, self.scrollView.frame.size.height);

    
}


@end
