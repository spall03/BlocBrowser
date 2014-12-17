//
//  AppDelegate.m
//  BlocBrowser
//
//  Created by Stephen Palley on 12/15/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "AppDelegate.h"
#import "WebBrowserViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[WebBrowserViewController alloc] init]];
    
    [self.window makeKeyAndVisible];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title")
                                                    message:NSLocalizedString(@"I built an iOS web browser!", @"Welcome comment")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"That rules!", @"Welcome button title") otherButtonTitles:nil];
    [alert show];
    
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    UINavigationController *navigationVC = (UINavigationController *)self.window.rootViewController; //this is our root
    WebBrowserViewController *browserVC = [[navigationVC viewControllers] firstObject]; //this is the web browser
    [browserVC resetWebView];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
