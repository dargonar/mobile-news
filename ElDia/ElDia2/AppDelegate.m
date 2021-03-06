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
#import "MenuClasificadosViewController.h"
#import "MobiImage.h"
#import "DiskCache.h"
#import "ConfigHelper.h"


#import "iVersion.h"
//#import <BugSense-iOS.framework/BugSenseCrashController.h> //dSYM
#import <BugSense-iOS/BugSenseController.h> //dSYM

#import "MySHKConfigurator.h"
#import "SHKConfiguration.h"
#import "SHKFacebook.h"
#import "GAI.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController, menuClasificadosViewController, menuViewController, clasificadosViewController, farmaciaViewController, carteleraViewController;
@synthesize navigationController;
@synthesize download_queue;


+ (void)initialize
{
  //  HACK
  [iVersion sharedInstance].ignoredVersion=nil;
  [iVersion sharedInstance].showOnFirstLaunch = NO;
  [iVersion sharedInstance].applicationBundleID = [AppDelegate getBundleId];
  //[iVersion sharedInstance].appStoreID = 578331790;
}

+ (NSString*) getBundleId{
  return [[[NSBundle mainBundle] bundleIdentifier] stringByReplacingOccurrencesOfString:@"mobipaper" withString:@"eldia"];
}

int cache_size = 2; //30;
-(void)checkCacheSize{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [[DiskCache defaultCache] purge];
  });
  return;
}

-(void)initGAI{

  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  
  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;
  
  // Optional: set Logger to VERBOSE for debug information.
  [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
  // ELDIA UA-39206160-1
  // TESTING UA-32663760-1
}

-(BOOL)isLandscape{
  //  UIDeviceOrientation   orientation = [UIDevice currentDevice].orientation;
  UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

  return UIDeviceOrientationIsLandscape(orientation);// ? @"Landscape" : @"Portrait";

}

-(BOOL)isiPad{
  
#ifdef UI_USER_INTERFACE_IDIOM
  return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
  return NO;
#endif
  //return ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self initGAI];
  [BugSenseController sharedControllerWithBugSenseAPIKey:@"c80eb89d"];

  NSString* rootFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  [[DiskCache defaultCache] configure:rootFolder cache_size:cache_size];

  NSString* cache_folder = [[DiskCache defaultCache] getFolder];

  NSString *appFolder = [[NSBundle mainBundle] resourcePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSError *err=nil;

  NSString* cssFolder = [cache_folder stringByAppendingPathComponent:@"css"];
  NSString* imgFolder = [cache_folder stringByAppendingPathComponent:@"img"];
  NSString* jsFolder  = [cache_folder stringByAppendingPathComponent:@"js"];
  //NSString* versionFile = [jsFolder stringByAppendingPathComponent:@"version_1_3_10.txt"];
  
  NSString *linkDestination = [fileManager destinationOfSymbolicLinkAtPath:jsFolder error:NULL];
  // Si existe la carpeta y no existe el archivo, aniquilo los links.
  if(![fileManager fileExistsAtPath:jsFolder] || ![fileManager fileExistsAtPath:linkDestination])
  {
    NSError *error;
    [fileManager removeItemAtPath:imgFolder error:&error];
    [fileManager removeItemAtPath:cssFolder error:&error];
    [fileManager removeItemAtPath:jsFolder error:&error];
  }
  
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
  
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(onDownloadImages:) 
                                               name:@"com.diventi.mobipaper.download_images"
                                             object:nil];
  
  
  //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//HACKED
  self.window = [[TapDetectingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//HACKED
  self.window.backgroundColor = [UIColor whiteColor];//HACKED
  
  // create the content view controller using the LogoExpandingViewController for no particular reason
  NSString *mainNibName           = @"MainViewController";
  NSString *menuNibName           = @"MenuViewController";
  NSString *menuClasificadosNibName   = @"MenuClasificadosViewController";
  NSString *clasificadosNibName       =@"ClasificadosViewController";
  if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
    mainNibName = @"MainViewController_iPad";
    menuNibName = @"MenuViewController_iPad";
    menuClasificadosNibName  = @"MenuClasificadosViewController_iPad";
    clasificadosNibName       =@"ClasificadosViewController_iPad";
  }
  self.menuViewController         = [[MenuViewController alloc] initWithNibName:menuNibName bundle:nil];
  self.mainViewController         = [[MainViewController alloc] initWithNibName:mainNibName bundle:nil];
  self.menuClasificadosViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];
  //[[MenuClasificadosViewController alloc] initWithNibName:menuClasificadosNibName bundle:nil];
  self.clasificadosViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];

  self.farmaciaViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];
  self.carteleraViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];

  
  navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
  self.navigationController.navigationBar.hidden = YES;
  
  //[self.window addSubview:self.navigationController.view];
  [self.window setRootViewController:self.navigationController];
  [self.window makeKeyAndVisible];//HACKED
  
  
  DefaultSHKConfigurator *configurator = [[MySHKConfigurator alloc] init];
  [SHKConfiguration sharedInstanceWithConfigurator:configurator];
  
  [self checkCacheSize];
  return YES;
}

/* ShareKit */
- (BOOL)handleOpenURL:(NSURL*)url
{
  NSString* scheme = [url scheme];
  NSString* prefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
  if ([scheme hasPrefix:prefix])
    return [SHKFacebook handleOpenURL:url];
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  return [self handleOpenURL:url];
}




-(void)loadMenu:(BOOL)useCache{
  NSLog(@"app_delegate::loadMenu useCache:%@", useCache?@"SI":@"NO");
  [self.menuViewController loadUrl:useCache];
}

-(void)loadService:(NSURL*)url{
  [self loadSectionNews:url];
}
-(void)loadSectionNews:(NSURL*)url{
  self.mainViewController.currentUrl = [url absoluteString];
  [self.mainViewController loadUrlAndLoading:self.mainViewController.currentUrl useCache:YES];
}

-(void)loadClasificados:(NSURL*)url{
  [self.clasificadosViewController loadClasificados:url];
}

-(void)loadMenuClasificados:(NSURL*)url{
  [self.menuClasificadosViewController loadMenuClasificados:url];
}

-(void)loadFunebres:(NSURL*)url{
  [self.clasificadosViewController loadFunebres:url];
}

-(void)showClasificados{
  [navigationController pushViewController:self.clasificadosViewController animated:YES ];
}

-(void)loadFarmacia:(NSURL*)url{
  [self.farmaciaViewController loadFarmacia:url];
}

-(void)loadCartelera:(NSURL*)url{
  [self.carteleraViewController loadCartelera:url];
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

-(void)hideSideMenuPushCartelera{
  [navigationController popToViewController:mainViewController animated:NO];
  [navigationController pushViewController:self.carteleraViewController animated:YES ];
}

-(void)hideSideMenuPushFarmacia{
  [navigationController popToViewController:mainViewController animated:NO];
  [navigationController pushViewController:self.farmaciaViewController animated:YES ];
}

-(void)hideSideMenuPushFunebres{
  [navigationController popToViewController:mainViewController animated:NO];
  [navigationController pushViewController:self.clasificadosViewController animated:YES ];
}

-(void)hideSideMenuPushClasificados{
  [navigationController popToViewController:mainViewController animated:NO];
  [navigationController pushViewController:self.clasificadosViewController animated:YES ];
}

-(void)hideSideMenuPushMenuClasificados{
  [navigationController popToViewController:mainViewController animated:NO];
  [navigationController pushViewController:self.menuClasificadosViewController animated:YES ];
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
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    
    NSLog(@"---------------------------------");
    NSLog(@"-- A Descargar %@", [[request url] absoluteString]);
    
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
  
  
  NSLog(@"---------------------------------");
  NSLog(@"-- requestDone %@", [[request url] absoluteString]);
  
  [[NSNotificationCenter defaultCenter] 
    postNotificationName:@"com.diventi.mobipaper.image_downloaded" 
                  object:data != nil ? image : nil
                userInfo:params];

}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
  NSDictionary *params = [request userInfo];
  NSLog(@"---------------------------------");
  NSLog(@"-- requestWentWrong %@", [[request url] absoluteString]);
  [[NSNotificationCenter defaultCenter] 
    postNotificationName:@"com.diventi.mobipaper.image_downloaded" 
                  object:nil
                userInfo:params];
}
@end
