//
//  ShowPictureController.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/28.
//

#import "ShowPictureController.h"

@interface ShowPictureController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation ShowPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageV.image = self.showImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
