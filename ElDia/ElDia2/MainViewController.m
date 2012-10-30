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


@implementation MainViewController
@synthesize myNoticiaViewController, refresh_loading_indicator, btnRefreshClick, loading_indicator, logo_imgvw_alpha, welcome_view, offline_imgvw, offline_lbl, error_view, btnRefresh2, refresh_loading_indicator2;

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

  if([self.mScreenManager sectionExists:mainUrl])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getSection:mainUrl useCache:YES error:&err];
    [self setHTML:data url:mainUrl];
    splashOn=NO;
    return;
  }
  
  splashOn=YES;
  [self showWelcomeLoadingIndicator];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

  NSString* url = [self.currentUrl copy];

  NSDate * date =[self.mScreenManager sectionDate:url];
  if( ![self isOld:date])
    return;
  
  [self reloadUrl:url useCache:YES];
  
}

-(void)reloadUrl:(NSString*)url useCache:(BOOL)useCache {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getSection:self.currentUrl useCache:useCache error:&err];
    //data=nil;
    dispatch_async(dispatch_get_main_queue(), ^{
      if(data==nil)
      {
        if(errorOn)
        {
          [self.refresh_loading_indicator2 stopAnimating];
          self.btnRefresh2.hidden=NO;
        }
        if(splashOn)
        {
          self.error_view.hidden=NO;
          [self hideLoadingIndicator];
          //paro el loading del splash y muestro un ewarning  + un boton de reload.
        }
        return;
      }
      
      [self setHTML:data url:url];
      
      data=nil;
      
      
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

//  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"update_all_images()"];
//  return;
  
  [self showRefreshLoadingIndicator];
  //ToDo
  NSString* url = [self.currentUrl copy];
  [self reloadUrl:url useCache:NO];
}

- (IBAction) btnRefresh2Click: (id)param{
  self.btnRefresh2.hidden=YES;
  self.refresh_loading_indicator2.hidden=NO;
  [self.refresh_loading_indicator2 startAnimating];
  errorOn=YES;
  NSString* url = [self.currentUrl copy];
  [self reloadUrl:url useCache:NO];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) showRefreshLoadingIndicator{
  btnRefreshClick.hidden=YES;
  btnRefreshClick.enabled=NO;
  self.refresh_loading_indicator.hidden = NO;
  [self.refresh_loading_indicator startAnimating];
}
-(void) showMainLoadingIndicator{
  self.loading_indicator.hidden = NO;
  [self.loading_indicator startAnimating];
  [self showRefreshLoadingIndicator];
}
-(void) showWelcomeLoadingIndicator{
  welcome_view.hidden = NO;
  [self showRefreshLoadingIndicator];
}


-(void) hideLoadingIndicator{
  self.loading_indicator.hidden = YES;
  [self.loading_indicator stopAnimating];
  
  [self hideRefreshLoadingIndicator];
  
  welcome_view.hidden = YES;
  
  self.logo_imgvw_alpha.hidden = YES;
 
}
-(void) hideRefreshLoadingIndicator{
  btnRefreshClick.hidden=NO;
  btnRefreshClick.enabled=YES;
  self.refresh_loading_indicator.hidden = YES;
  [self.refresh_loading_indicator stopAnimating];
}

-(void)showMessage:(NSString*)message{
  NSInteger top=50;
  top=80;
  
  [[[iToast makeText:message] setGravity:iToastGravityTop offsetLeft:0 offsetTop:top] show];

}

// UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  NSLog(@"WEBVIEW: end load with error");
  NSLog(@"Error: %@ %@", error, [error userInfo]);

  //ToDo: mostrar algo sif necessary.
  [self hideLoadingIndicator];
  self.error_view.hidden=YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
  NSLog(@"WEBVIEW: start load");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"update_all_images()"];
  NSLog(@"WEBVIEW: end load");
  [self hideLoadingIndicator];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType{
  
  
  NSURL* url = [request URL];
  if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:SCHEMA_NOTICIA])
  {

    if (self.myNoticiaViewController != nil) {
      [self.myNoticiaViewController loadBlank];
    }
    if (self.myNoticiaViewController == nil) {
      [self loadNoticiaView];      
    }
    
    [app_delegate.navigationController pushViewController:myNoticiaViewController animated:YES];
    
    [self.myNoticiaViewController loadNoticia:[[url host] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]]];
    
    
    NSLog(@"webView: DESPUES de cargar Noticia");

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
