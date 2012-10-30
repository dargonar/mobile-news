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


@implementation MainViewController
@synthesize myNoticiaViewController, refresh_loading_indicator, btnRefreshClick, loading_indicator, logo_imgvw_alpha, welcome_view, offline_imgvw, offline_lbl, error_view, btnRefresh2, refresh_loading_indicator2, mainUIWebView, welcome_indicator;

BOOL splashOn=NO;
BOOL errorOn=NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configureToast];
      splashOn = NO;
      errorOn = NO;
    }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSString *mainUrl = @"section://main";
  [self setCurrentUrl:mainUrl];
  
  // 1 Vemos si tenemos cacheada la pantalla y la mostramos.
  //   No importa que tan vieja sea.
  
  if([self.mScreenManager sectionExists:mainUrl])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getSection:mainUrl useCache:YES error:&err];
    [self setHTML:data url:mainUrl webView:self.mainUIWebView];
    [app_delegate loadMenu:YES];
    splashOn=NO;
    return;
  }
  
  [self onWelcome:YES];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

  NSString* url = [self.currentUrl copy];
  
  // 2 Cuando aparece la vista intentamos traernos todo si lo cacheado es viejo (o no teniamos nada!).
  NSDate * date =[self.mScreenManager sectionDate:url];
  
  if( ![self isOld:date])
    return;
  
  [self loadUrl:url useCache:YES];
  
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getSection:self.currentUrl useCache:useCache error:&err];

    dispatch_async(dispatch_get_main_queue(), ^{
      
      if(data==nil)
      {
        /*if(errorOn)
        {
          [self onError:NO];
        }
        if(splashOn)	
        {
          [self onNothing];
        }*/
        [self onNothing];
        if([err code]==ERR_NO_INTERNET_CONNECTION)
        {
          [self showMessage:@"No hay conexion de red.\nNo podemos actualizar la aplicacion."];
        }
        else
          [self onError:NO];
        
        return;
      }
      
      [self setHTML:data url:url webView:self.mainUIWebView];
      
      data=nil;
      
      [app_delegate loadMenu:NO];
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
  [app_delegate showSideMenu];
}

- (IBAction) btnRefreshClick: (id)param{
  [self onRefreshing:YES];
  //ToDo
  NSString* url = [self.currentUrl copy];
  [self loadUrl:url useCache:NO];
}

- (IBAction) btnRefresh2Click: (id)param{
  [self onErrorRefreshing:YES];
  NSString* url = [self.currentUrl copy];
  [self loadUrl:url useCache:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

  [self onRefreshing:started];
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
  NSLog(@"WEBVIEW: end load");
  [self onNothing];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType{
  
  
  NSURL* url = [request URL];
  if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"noticia"])
  {

    if (self.myNoticiaViewController != nil) {
      [self.myNoticiaViewController loadBlank];
    }
    if (self.myNoticiaViewController == nil) {
      [self loadNoticiaView];      
    }
    
    [app_delegate.navigationController pushViewController:myNoticiaViewController animated:YES];
    
    [self.myNoticiaViewController loadNoticia:url];
    
    return NO;
  }
  return YES;
  
}

-(void) loadNoticiaView{
  
  NSString *noticiaNibName = @"NoticiaViewController";
  if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
    noticiaNibName = @"NoticiaViewController_iPad";
  }
  self.myNoticiaViewController= [[NoticiaViewController alloc]
                                 initWithNibName:noticiaNibName bundle:[NSBundle mainBundle]];
  self.myNoticiaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  
}

@end
