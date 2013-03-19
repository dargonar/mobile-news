//
//  MainViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MainViewController.h"
#import "iToast.h"
#import "ConfigHelper.h"
#import "AppDelegate.h"
#import "ErrorBuilder.h"
#import "Utils.h"
#import "NewsManager.h"
#import "XMLParser.h"

@implementation MainViewController
@synthesize myNoticiaViewController, refresh_loading_indicator, btnRefreshClick,btnOptions, loading_indicator, logo_imgvw_alpha, welcome_view, offline_view, error_view, btnRefresh2, refresh_loading_indicator2, welcome_indicator;
@synthesize mainUIWebView, menu_webview;
@synthesize header, logo;

BOOL splashOn=NO;
BOOL errorOn=NO;
BOOL refreshingOn=NO;
NSLock *menuLock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self configureToast];
      splashOn = NO;
      errorOn = NO;
      refreshingOn=NO;
      self.btnOptions.enabled=NO;
      menuLock = [[NSLock alloc] init];
    }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSString *mainUrl = @"section://main";
  [self setCurrentUrl:mainUrl];
  
  mainUIWebView.tag=MAIN_VIEW_TAG;
  //if ([app_delegate isiPad]) {
    [[self mainUIWebView] setScalesPageToFit:YES];
    [[self menu_webview] setScalesPageToFit:YES];
    
  //}
  if([app_delegate isLandscape])
  {
    [self positionateLandscape];
  }
  
  // 1 Vemos si tenemos cacheada la pantalla y la mostramos.
  //   No importa que tan vieja sea.
  
  if([self.mScreenManager sectionExists:mainUrl])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getSection:mainUrl useCache:YES error:&err];
    [self setHTML:data url:mainUrl webView:self.mainUIWebView];
    [self loadMenu:YES];
    splashOn=NO;
    return;
  }
  
  [self onWelcome:YES];
}

-(void)reLoadIndex{
  NSString*uri=[self currentUrl];
  if([self.mScreenManager sectionExists:uri])
  {
    NSError *err;
    NSData*lastData = [self.mScreenManager getSection:uri useCache:YES error:&err];
    [self setHTML:lastData url:uri webView:self.mainUIWebView];
  }
  else
  {
    [self loadUrl:uri useCache:YES];
  }
}

-(void)loadMenu:(BOOL)useCache{
  
  if([self.mScreenManager menuExists])
  {
    NSLog(@"MainViewController::loadMenu menu exists!");
    self.btnOptions.enabled=YES;
    if(useCache)
      return;
  }
  
  [app_delegate loadMenu:useCache];
  
}
- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

  NSString* url = [self.currentUrl copy];
  
  NSDate * date =[self.mScreenManager sectionDate:url];
  // Main list es muy viejo?
  if( ![self isOld:date])
    return;
  
  // Lo traemos de nuevo
  [self loadUrl:url useCache:NO reloadMenu:YES];
  
}

-(void)loadUrlAndLoading:(NSString*)url useCache:(BOOL)useCache{
  [self onRefreshing:YES];
  [self loadUrl:url useCache:useCache reloadMenu:NO];
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache {
  [self loadUrl:url useCache:useCache reloadMenu:NO];
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache reloadMenu:(BOOL)reloadMenu {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getSection:self.currentUrl useCache:useCache error:&err];

    dispatch_async(dispatch_get_main_queue(), ^{
      
      if(data==nil)
      {
        if(splashOn) //quiere decir que no habia nada cacheado... la primera vez?
        {
          //1: Saco el splash.
          [self onWelcome:NO];
          //2: Muestro pantalla de error.
          [self onError:YES];
        }
        
        if(errorOn)
        {
          //Si estaba mostrando pantalla de error, detengo el indicator.
          [self onErrorRefreshing:NO];
        }
        
        if(refreshingOn)
        {
          [self onRefreshing:NO];
        }
        
        if([err code]==ERR_NO_INTERNET_CONNECTION)
        {
          [self showMessage:@"No hay conexión de red.\nNo podemos actualizar la aplicación." isError:YES];
        }
        
        return;
      }
      
      [self setHTML:data url:url webView:self.mainUIWebView];
      
      data=nil;
      if(reloadMenu)
        [self loadMenu:useCache];
    });
  });
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.mScreenManager=nil;
  
  self.myNoticiaViewController =nil;
  
  self.btnRefreshClick = nil;
  self.mainUIWebView= nil;
  self.refresh_loading_indicator= nil;
  self.welcome_view=nil;
} 

- (IBAction) btnOptionsClick: (id)param{
  if(![menuLock tryLock])
    return;
  [app_delegate showSideMenu];
  [menuLock unlock];
}

NSInteger soto = 0;
- (IBAction) btnRefreshClick: (id)param{

  [self onRefreshing:YES];
  //ToDo
  NSString* url = [self.currentUrl copy];
  [self loadUrl:url useCache:NO reloadMenu:YES];
}

- (IBAction) btnRefresh2Click: (id)param{
  [self onErrorRefreshing:YES];
  NSString* url = [self.currentUrl copy];
  [self loadUrl:url useCache:NO];
}


// HACK: Estaba comentado
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (BOOL) shouldAutorotate
{
  return YES; //[app_delegate isiPad];
}

-(NSUInteger)supportedInterfaceOrientations
{
  //return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft;
  //return UIInterfaceOrientationMaskAll;
  return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait ;
}

BOOL isShowingLandscapeView = NO;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  
  if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
      !isShowingLandscapeView)
  {
    [self positionateLandscape];
  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
           isShowingLandscapeView)
  {
    [self positionatePortrait];
  }
  
  [self reLoadIndex];
}

-(void)positionateLandscape{
  
  isShowingLandscapeView = YES;
  
  if ([app_delegate isiPad]) {
    //NSInteger  width=self.view.frame.size.width;
    NSInteger  height=self.view.frame.size.height;
    // x y width height

    //self.mainUIWebView.frame=CGRectMake(width/2, 44, width/2, height-44);
    self.mainUIWebView.frame=CGRectMake(256, 44, 1024-256, height-44);
    
    
    self.btnOptions.hidden=YES;
    self.btnOptions.enabled=NO;
    
    //self.menu_webview.frame=CGRectMake(0, 44, width/2, height-44);
    self.menu_webview.frame=CGRectMake(0, 44, 256, height-44);
    self.menu_webview.hidden = NO;
    [self.menu_webview reload];
    [self loadMenu];
  }
  else{
    
  }
  
  [self.mainUIWebView reload];
}


-(void)positionatePortrait{
  isShowingLandscapeView = NO;
  
  if ([app_delegate isiPad]) {
    NSInteger  width=self.view.frame.size.width;
    NSInteger  height=self.view.frame.size.height;
    // x y width height
    self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44);
    [self.mainUIWebView reload];
  
    self.menu_webview.hidden = YES;
  
    self.btnOptions.hidden=NO;
    self.btnOptions.enabled=YES;
  }
  else{
    
  }
  
  [self.mainUIWebView reload];

}


-(void)loadMenu{
  if ([app_delegate isiPad]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      __block NSError *err;
      __block NSData *data = [self.mScreenManager getMenu:YES error:&err];
      dispatch_async(dispatch_get_main_queue(), ^{
        if(data==nil)
        {
          // data = dummy;
        }
        else
        {
          [self setHTML:data url:nil webView:self.menu_webview];
        }
        data=nil;
      });
    });
  }
}

-(void) onErrorRefreshing:(BOOL)started{
  self.btnRefresh2.hidden=started;
  self.refresh_loading_indicator2.hidden=!started;
  if(started)
    [self.refresh_loading_indicator2 startAnimating ];
  else
    [self.refresh_loading_indicator2 stopAnimating ];
      
  //errorOn=!started;
}

-(void) onRefreshing:(BOOL)started{
  btnRefreshClick.hidden=started;
  btnRefreshClick.enabled=!started;
  self.refresh_loading_indicator.hidden = !started;
  if(started)
      [self.refresh_loading_indicator startAnimating ];
  else
    [self.refresh_loading_indicator stopAnimating ];
  refreshingOn=started;
}

-(void) onLoading:(BOOL)started{
  self.loading_indicator.hidden = !started;
  if(started)
    [self.loading_indicator startAnimating ];
  else
    [self.loading_indicator stopAnimating ];

  [self onRefreshing:started];
}

-(void) onWelcome:(BOOL)started{
  welcome_view.hidden = !started;
  if(started)
    [self.welcome_indicator startAnimating ];
  else
    [self.welcome_indicator stopAnimating ];

  //[self onRefreshing:started];
  splashOn=started;
  
}

-(void) onError:(BOOL)started{
  error_view.hidden = !started;
  [self onErrorRefreshing:NO];
  errorOn=started;
}

-(void) onNothing{
  //[self onRefreshing2:NO];
  [self onRefreshing:NO];
  [self onWelcome:NO];
  [self onError:NO];
  [self onLoading:NO];
}

// UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  NSLog(@"WEBVIEW: end load with error");
  NSLog(@"Error: %@ %@", error, [error userInfo]);

  [self onNothing];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
  NSLog(@"WEBVIEW: start load");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"update_all_images()"];
  [self showUpdatedAt];
  [self onNothing];
  //[self showMessage:@"Esto es una prueba.\nNo pretendemos ser dios." isError:YES];
}

-(void)showUpdatedAt{
  
  NSDate * date =[self.mScreenManager sectionDate:self.currentUrl];
  NSString *jsString  = [NSString  stringWithFormat:@"show_actualizado('%@')", [Utils timeAgoFromUnixTime:[date timeIntervalSince1970]]];
  
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  
  jsString=nil;
  date=nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType{
  
  
  NSURL* url = [request URL];
  
  if(webView.tag == MAIN_VIEW_TAG)
  {
    if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"noticia"])
    {
      if (self.myNoticiaViewController != nil) {
        [self.myNoticiaViewController loadBlank];
      }
      if (self.myNoticiaViewController == nil) {
        [self loadNoticiaView];
      }
    
      [app_delegate.navigationController pushViewController:myNoticiaViewController animated:YES];
    
      NSLog(@" call load noticia: %@", [url absoluteString]);
      [self.myNoticiaViewController loadNoticia:url section:self.currentUrl];
    
      return NO;
    }
  }
  else{
    if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"section"])
    {
      [app_delegate loadSectionNews:url];
      return NO;
    }
    else
      if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"clasificados"])
      {
        [app_delegate loadClasificados:url];
        return NO;
      }
  }
  return YES;
  
}

-(void) loadNoticiaView{
  
  NSString *noticiaNibName = @"NoticiaViewController";
  if([app_delegate isiPad]) {
    noticiaNibName = @"NoticiaViewController_iPad";
  }
  self.myNoticiaViewController= [[NoticiaViewController alloc]
                                 initWithNibName:noticiaNibName bundle:[NSBundle mainBundle]];
  self.myNoticiaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  
}

@end
