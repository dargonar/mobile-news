//
//  AppDelegate.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MenuViewController.h"
#import "ClasificadosViewController.h"
#import "MobiImage.h"
#import "DiskCache.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController, clasificadosViewController, menuViewController;
@synthesize navigationController;
@synthesize download_queue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSString* rootFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  [[DiskCache defaultCache] configure:rootFolder cache_size:5];

  NSString* cache_folder = [[DiskCache defaultCache] getFolder];

  NSString *appFolder = [[NSBundle mainBundle] resourcePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSError *err=nil;

  NSString* cssFolder = [cache_folder stringByAppendingPathComponent:@"css"];
  NSString* imgFolder = [cache_folder stringByAppendingPathComponent:@"img"];
  NSString* jsFolder  = [cache_folder stringByAppendingPathComponent:@"js"];
  
  if (![fileManager fileExistsAtPath:cssFolder]) {
    [fileManager createSymbolicLinkAtPath:cssFolder withDestinationPath:appFolder error:&err];
    NSLog(@"Error1: %@", err != nil ? [err description] : @"NIL");
  }

  if (![fileManager fileExistsAtPath:imgFolder]) {
    [fileManager createSymbolicLinkAtPath:imgFolder withDestinationPath:appFolder error:&err];
    NSLog(@"Error2: %@", err != nil ? [err description] : @"NIL");
  }

  if (![fileManager fileExistsAtPath:jsFolder]) {
    [fileManager createSymbolicLinkAtPath:jsFolder withDestinationPath:appFolder error:&err];
    NSLog(@"Error3: %@", err != nil ? [err description] : @"NIL");
  }

  NSLog(@"Cache current size: %llu", [[DiskCache defaultCache] size]);
  
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(onDownloadImages:) 
                                               name:@"com.diventi.mobipaper.download_images" 
                                             object:nil];
  
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//HACKED
  self.window.backgroundColor = [UIColor whiteColor];//HACKED
  
  // create the content view controller using the LogoExpandingViewController for no particular reason
  NSString *mainNibName           = @"MainViewController";
  NSString *menuNibName           = @"MenuViewController";
  NSString *clasificadosNibName   = @"ClasificadosViewController";
  if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
    mainNibName = @"MainViewController_iPad";
    menuNibName = @"MenuViewController_iPad";
    clasificadosNibName  = @"clasificadosViewController_iPad";
  }
  self.menuViewController         = [[MenuViewController alloc] initWithNibName:menuNibName bundle:nil];
  self.mainViewController         = [[MainViewController alloc] initWithNibName:mainNibName bundle:nil];
  self.clasificadosViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];
  
  navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
  self.navigationController.navigationBar.hidden = YES;
  //[navigationController pushViewController:self.mainViewController animated:NO];
  //[self.mainViewController release];
  //  self.mainViewController = navigationController;
  [self.window addSubview:self.navigationController.view];
  [self.window makeKeyAndVisible];//HACKED
  
  
  //HACK SACAR ANTES DE RELEASE
  //[NSClassFromString(@"WebView") performSelector:@selector(_enableRemoteInspector)];
  //id sharedServer = [NSClassFromString(@"WebView") performSelector:@selector(sharedWebInspectorServer)];
  
  return YES;
}

-(void)loadMenu:(BOOL)useCache{
  [self.menuViewController loadUrl:useCache];
}

-(void)loadSectionNews:(NSURL*)url{
  self.mainViewController.currentUrl = [url absoluteString];
  [self.mainViewController loadUrl:self.mainViewController.currentUrl useCache:YES];
}

-(void)loadClasificados:(NSURL*)url{
  [self.clasificadosViewController loadClasificados:url];
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

-(void)hideSideMenu2{
  [navigationController popToViewController:mainViewController animated:NO];
  [navigationController pushViewController:self.clasificadosViewController animated:YES ];
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

- (void)onDownloadImages:(NSNotification *)notif {

  if (notif == nil) {
    return;
  }
  
  //NSLog(@"aguanto ..");
  //sleep(5);
  //NSLog(@"salgo ..");
  
  if (![self download_queue]) {
    self.download_queue = [[NSOperationQueue alloc] init];
    [self.download_queue setMaxConcurrentOperationCount:20]; //20 al mismo tiempo?
  }

  NSArray   *mobi_images = [notif object];
  NSDictionary *userInfo = [notif userInfo];
  if(mobi_images == nil || userInfo == nil) {
    return;
  }
    
  for (int i=0; i<[mobi_images count]; i++) {

    MobiImage *mobi_image = [mobi_images objectAtIndex:i];
    if (mobi_image == nil) {
      continue;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                              mobi_image, @"mi", 
                              [userInfo objectForKey:@"url"], @"url", 
                              nil];

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
  NSDictionary *params = [request userInfo];
  MobiImage *image = [params objectForKey:@"mi"];
  
  NSData *data = [request responseData];
  
  if (data != nil) {
    [[DiskCache defaultCache] put:image.local_uri data:data prefix:@"i"];
  }
  
  [[NSNotificationCenter defaultCenter] 
    postNotificationName:@"com.diventi.mobipaper.image_downloaded" 
                  object:data != nil ? image : nil
                userInfo:params];

}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
  NSDictionary *params = [request userInfo];

  [[NSNotificationCenter defaultCenter] 
    postNotificationName:@"com.diventi.mobipaper.image_downloaded" 
                  object:nil
                userInfo:params];
}
@end
