//
//  AppDelegate.m
//  VisitManager
//
//  Created by 李鹏跃 on 2022/4/16.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    [self.window makeKeyAndVisible];
    if (@available(iOS 11.0, *)) {

        UITableView.appearance.estimatedRowHeight = 0;

        UITableView.appearance.estimatedSectionFooterHeight = 0;

        UITableView.appearance.estimatedSectionHeaderHeight = 0;

        UITableView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    }
    return YES;
}

@end
