//
//  AppDelegate.m
//  RunnerTracker
//
//  Created by Xinjun on 23/10/13.
//  Copyright (c) 2013 Xinjun. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"


@implementation UITabBarController (Background)

-(BOOL)shouldAutorotate
{
    //I don't want to support auto rotate, but you can return any value you want here
    return NO;
}

//- (NSUInteger)supportedInterfaceOrientations {
//    //I want to only support portrait mode
//    return UIInterfaceOrientationMaskPortrait;
//}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /*UINavigationController *nav = [[UINavigationController alloc] init];
    MapViewController *mapVC = [[MapViewController alloc] init];
    
    [nav pushViewController:mapVC animated:NO];
    self.window.rootViewController = nav;*/
    
    NSArray *para = [NSArray arrayWithObjects: [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", nil], nil];
    BOOL bRet = [NSJSONSerialization isValidJSONObject:para];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:para options:0 error:NULL];
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%d, %@", bRet, data);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
