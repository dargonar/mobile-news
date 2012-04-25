//
//  AppDelegate.m
//  MobiPaper
//
//  Created by Matias on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "HomeController.h"
#import "MyUtils.h"

#import <SystemConfiguration/SystemConfiguration.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize homeController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.homeController = [[HomeController alloc] initWithNibName:stripPadSuffixOnPhone(@"Home~ipad") bundle:nil];

    self.window.rootViewController = self.homeController;
    [self.window makeKeyAndVisible];

    //La vista de loading
    HUD = [[MBProgressHUD alloc] initWithView:self.homeController.view];
    HUD.labelText = @"Cargando";
    
    // Override point for customization after app launch    
    [self.window addSubview:HUD];

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

- (BOOL)isDataSourceAvailable {
	BOOL _isDataSourceAvailable;
	Boolean success;    
	const char *host_name = "ymobipaper.appspot.com";
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
	SCNetworkReachabilityFlags flags;
	success = SCNetworkReachabilityGetFlags(reachability, &flags);
	_isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
    return _isDataSourceAvailable;
}

- (void)showLoading:(BOOL)animated{
    if (animated) {
        [HUD show:1];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else {
        [HUD hide:1];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }
}


@end
