//
//  AppDelegate.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MobiImage.h"
#import "DiskCache.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController;
@synthesize menuViewController, navigationController;
@synthesize download_queue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  NSString* rootFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  [[DiskCache defaultCache] configure:rootFolder];
  
  //LocalSubstitutionCache *cache = [[LocalSubstitutionCache alloc] init];
  //[NSURLCache setSharedURLCache:cache];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//HACKED
  self.window.backgroundColor = [UIColor whiteColor];//HACKED
  
  // create the content view controller using the LogoExpandingViewController for no particular reason
  NSString *mainNibName = @"MainViewController";
  NSString *menuNibName = @"MenuViewController";
  if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
    mainNibName = @"MainViewController_iPad";
    menuNibName = @"MenuViewController_iPad";
  }
  self.mainViewController = [[MainViewController alloc] initWithNibName:mainNibName bundle:nil];
  
  // create the menuViewController also in the app delegate so we can swap it in as the
  // windows root view controller whenever its required
  self.menuViewController = [[MenuViewController alloc] initWithNibName:menuNibName bundle:nil];
  
  // set the rootViewController to the contentViewController
  //self.window.rootViewController = self.mainViewController;//HACKED
  //[self.window makeKeyAndVisible];//HACKED
  
  //[self.navigationController pushViewController:self.mainViewController animated:YES];
  navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
  self.navigationController.navigationBar.hidden = YES;
  //[navigationController pushViewController:self.mainViewController animated:NO];
  //[self.mainViewController release];
  //  self.mainViewController = navigationController;
  [self.window addSubview:self.navigationController.view];
  [self.window makeKeyAndVisible];//HACKED
  
  
  return YES;
}


-(void)showSideMenu
{
  // before swaping the views, we'll take a "screenshot" of the current view
  // by rendering its CALayer into the an ImageContext then saving that off to a UIImage
  CGSize viewSize = self.mainViewController.view.bounds.size;
  UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
  [self.mainViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  // Read the UIImage object
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  // pass this image off to the MenuViewController then swap it in as the rootViewController
  self.menuViewController.screenShotImage = image;
  //self.window.rootViewController = self.menuViewController; //HACKED
  [navigationController pushViewController:self.menuViewController animated:NO ];
}

-(void)hideSideMenu
{
  // all animation takes place elsewhere. When this gets called just swap the contentViewController in
  //self.window.rootViewController = self.mainViewController;//HACKED
  //  [navigationController pushViewController:self.mainViewController animated:NO ];
  [navigationController popToViewController:mainViewController animated:NO];

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

- (void)downloadImages:(NSArray *)mobi_images {

  if (![self download_queue]) {
    self.download_queue = [[NSOperationQueue alloc] init];
    [self.download_queue setMaxConcurrentOperationCount:20]; //20 al mismo tiempo?
  }
  
  for (int i=0; i<[mobi_images count]; i++) {

    MobiImage *mobi_image = [mobi_images objectAtIndex:i];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"mi", mobi_image, nil];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL: [NSURL URLWithString:mobi_image.url]];

    [request setUserInfo:params];

    //[request setNumberOfTimesToRetryOnTimeout:2];
    //[request setTimeOutSeconds:NSTimeIn]
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    
    [self.download_queue addOperation:request];  
  }
}

- (void)requestDone:(ASIHTTPRequest *)request
{
  
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{

}
@end
