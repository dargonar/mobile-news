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
      self.mainUIWebView.delegate=self;
      self.menu_webview.delegate=self;
    }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.primaryUIWebView= self.mainUIWebView;
  self.secondaryUIWebView= self.menu_webview;
  
  NSString *mainUrl = @"section://main";
  [self setCurrentUrl:mainUrl];
  
  mainUIWebView.tag=MAIN_VIEW_TAG;
  
  [[self mainUIWebView] setScalesPageToFit:NO];
  [self mainUIWebView].multipleTouchEnabled = NO;
  self.mainUIWebView.contentMode = UIViewContentModeScaleAspectFit;
  
  
  if ([app_delegate isiPad]) {
    [[self menu_webview] setScalesPageToFit:NO];
    [self menu_webview].multipleTouchEnabled = NO;
  }
  
  /*if([app_delegate isLandscape])
  {
    [self positionateLandscape];
  }*/
  
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
  [self loadUrl:uri useCache:YES];
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
  
  NSDate * date = [self getDate:url];
  
  // Main list es muy viejo?
  if( ![self isOld:date])
    return;
  
  // Lo traemos de nuevo
  [self loadUrl:url useCache:NO reloadMenu:([url hasPrefix:@"section://"])];
  
}


-(void)loadClasificadosAndLoading:(NSString*)url useCache:(BOOL)useCache{
  [self onRefreshing:YES];
  [self loadUrl:url useCache:useCache reloadMenu:NO];
}

-(void)loadUrlAndLoading:(NSString*)url useCache:(BOOL)useCache{
  [self onRefreshing:YES];
  [self loadUrl:url useCache:useCache reloadMenu:NO];
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache {
  [self loadUrl:url useCache:useCache reloadMenu:NO];
}

-(NSString*)getType:(NSString*)url{
  if( [url hasPrefix:@"clasificados://" ] ) {
    return @"clasificados";
  }
  else
    if( [url hasPrefix:@"funebres://" ] ) {
      return @"funebres";
    }
    else
      if( [url hasPrefix:@"farmacia://" ] ) {
        return @"farmacia";
      }
      else
        if( [url hasPrefix:@"cartelera://" ] ) {
          return @"cartelera";
        }
  return @"section";
  
}

-(NSDate*)getDate:(NSString*)url{
  if( [url hasPrefix:@"clasificados://" ] ) {
    return[self.mScreenManager clasificadosDate:url];
  }
  else
    if( [url hasPrefix:@"funebres://" ] ) {
      return[self.mScreenManager funebresDate:url];
    }
    else
      if( [url hasPrefix:@"farmacia://" ] ) {
        return[self.mScreenManager farmaciaDate:url];
      }
      else
        if( [url hasPrefix:@"cartelera://" ] ) {
          return[self.mScreenManager carteleraDate:url];
        }
  return[self.mScreenManager sectionDate:url];
}


-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache reloadMenu:(BOOL)reloadMenu {
  
  showUpdatedAt = YES;
  NSString*type= [self getType:url];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = nil;
    if([type isEqualToString:@"clasificados"])
    {
      data=[self.mScreenManager getClasificados:self.currentUrl useCache:useCache error:&err];
    }
    else
      if([type isEqualToString:@"funebres"])
      {
        data=[self.mScreenManager getFunebres:self.currentUrl useCache:useCache error:&err];
      }
      else
        if([type isEqualToString:@"farmacia"])
        {
          data=[self.mScreenManager getFarmacia:self.currentUrl useCache:useCache error:&err];
        }
        else
          if([type isEqualToString:@"cartelera"])
          {
            data=[self.mScreenManager getCartelera:self.currentUrl useCache:useCache error:&err];
          }
      else{
      data=[self.mScreenManager getSection:self.currentUrl useCache:useCache error:&err];
    }
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
        NSLog(@"%d", [err code]);
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
  [self positionate];
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

BOOL isLandscapeView_ = NO;
BOOL isLoading_ = YES;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
  [self positionate];
  
}

-(void) rotateHTML:(UIWebView*)webView{
  if([app_delegate isiPad])
    return;
  
  NSString *viewportWidth = @"";
  NSString *viewportInitScale = @"";
  NSString *viewportMaxScale = @"";
  
  viewportWidth = @"320";
  viewportInitScale = @"1.0";
  viewportMaxScale = @"1.0";
  if(isLandscapeView_==YES){
    //viewportWidth = @"480";
    viewportInitScale = @"1.5";
    viewportMaxScale = @"1.5";
    
  }
  
  //document.body.style.width = '%@px'; 
  NSString *jsString = [[NSString alloc] initWithFormat:@"metayi = document.querySelector('meta[name=viewport]'); metayi.setAttribute('content','width=%@; minimum-scale=%@; maximum-scale=%@; user-scalable=no;');",viewportWidth, viewportInitScale, viewportMaxScale  ];
  
  NSLog(@"%@",jsString);
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  
}


-(void)positionate{
  
  UIDeviceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
  
  [self positionateAdMainScreen:deviceOrientation];
  
  BOOL hasRotated = NO;
  if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
      !isLandscapeView_)
  {
    [self positionateLandscape];
    hasRotated = YES;
  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation) && (isLandscapeView_ || isLoading_))
  {
    [self positionatePortrait];
    hasRotated = YES;
  }
  
  [self rotateHTML:self.mainUIWebView];
  
  //HACK Testing
  if(hasRotated == YES)
    [self reLoadIndex];

  isLoading_=NO;

}

-(void)positionateLandscape{
  
  isLandscapeView_ = YES;
  NSInteger  width=self.view.frame.size.width;
  NSInteger  height=self.view.frame.size.height;
  
  if ([app_delegate isiPad]) {
    // x y width height

    self.mainUIWebView.frame=CGRectMake(256, 44, 1024-256, height-44-[self adHeight]);
    
    self.btnOptions.hidden=YES;
    self.btnOptions.enabled=NO;
    
    self.menu_webview.frame=CGRectMake(0, 44, 256, height-44);
    self.menu_webview.hidden = NO;
    [self.menu_webview reload];
    if(menuLoaded==NO)
    {
      menuLoaded=YES;
      [self loadMenu];
    }
  }
  else{
    self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44-[self adHeight]);
  }
  
  // HACK testing
  [self.mainUIWebView reload];
}

bool menuLoaded = NO;


-(void)positionatePortrait{
  isLandscapeView_ = NO;
  NSInteger  width=self.view.frame.size.width;
  NSInteger  height=self.view.frame.size.height;
  if ([app_delegate isiPad]) {
    // x y width height
    self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44-[self adHeight]);
    self.menu_webview.hidden = YES;
  
    self.btnOptions.hidden=NO;
    self.btnOptions.enabled=YES;
  }
  else{
    self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44-[self adHeight]);
  }
  
  // HACK testing
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

- (void)webViewDidStartLoad:(UIWebView *)webView{
  
  //[webView setScalesPageToFit:YES];
  NSString*webDesc = webView.tag==MAIN_VIEW_TAG?@"menuWebView":@"mainWebView";
  NSLog(@"WEBVIEW[%@] webViewDidStartLoad", webDesc);
  
  if(webView.tag == MAIN_VIEW_TAG){
    webView.hidden = YES;
  }
  
}

// UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [self onNothing];
  if(webView.tag == MAIN_VIEW_TAG){
    webView.hidden = NO;
  }
}

bool showUpdatedAt = NO;
- (void)webViewDidFinishLoad:(UIWebView *)webView{

  if(webView.tag == MAIN_VIEW_TAG )
  {
    [self onNothing];
    if([current_url hasPrefix:@"section"])
    {
      [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"update_all_images()"];
      [self showUpdatedAt];
    }
    webView.hidden = NO;
    if(![app_delegate isiPad])
    {
      [self rotateHTML:self.mainUIWebView];
    }
  }
}


-(void)showUpdatedAt{
  
  if(showUpdatedAt==NO)
    return;
  showUpdatedAt=NO;
  
  NSDate * date =[self getDate:self.currentUrl];
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
    
      NSLog(@" call load noticia: %@ ; section: %@", [url absoluteString], self.currentUrl);
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
      if (UIWebViewNavigationTypeLinkClicked == navigationType
          && ([[url scheme]isEqualToString:@"clasificados"]
              || [[url scheme]isEqualToString:@"funebres"]
              || [[url scheme]isEqualToString:@"farmacia"]
              || [[url scheme]isEqualToString:@"cartelera"]))
      {
        NSLog(@" main clicked: %@", url);
        [self setCurrentUrl:[url absoluteString]];
        [self loadUrlAndLoading:[url absoluteString] useCache:YES];
        
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
