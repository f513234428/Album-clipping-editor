//
//  AppDelegate.m
//  Album-clipping-editor
//
//  Created by syz on 2024/3/25.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    UINavigationController *loginNavi =[[UINavigationController alloc] initWithRootViewController:[[ViewController alloc]init]];
    self.window.rootViewController = loginNavi;

    return YES;
}


@end
