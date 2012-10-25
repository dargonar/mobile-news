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
@synthesize mYMobiPaperLib, myNoticiaViewController, refresh_loading_indicator, btnRefreshClick, loading_indicator, logo_imgvw_alpha, welcome_imgvw, welcome_indicator, offline_imgvw, offline_lbl;

BOOL splashOn=NO;
static MainViewController *sharedInstance = nil;
NSString *sectionId = nil;
BOOL cacheCleaned = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configureToast];
    }
  
  self.mYMobiPaperLib = [[YMobiPaperLib alloc] init];
  self.mYMobiPaperLib.delegate = self;

  sharedInstance = nil;
  sectionId = nil;
  cacheCleaned = NO;
  sharedInstance=self;
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setCurrentUrl:@"section://main"];

  if([self.mScreenManager sectionExists:self.currentUrl])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getSection:self.currentUrl useCache:YES error:&err];
    [self setHTML:data url:self.currentUrl];
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
  
  [self showRefreshLoadingIndicator];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getSection:self.currentUrl useCache:YES error:&err];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if(data==nil)
      {
        if(splashOn)
        {
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
  self.mYMobiPaperLib = nil;
  
  self.btnRefreshClick = nil;
  self.mainUIWebView= nil;
  self.refresh_loading_indicator= nil;
  self.welcome_imgvw=nil;
  self.welcome_indicator=nil;
} 

+(MainViewController *)sharedInstance{
  return sharedInstance;
}



- (IBAction) btnOptionsClick: (id)param{
  [app_delegate showSideMenu];
}

- (IBAction) btnRefreshClick: (id)param{

  
  [self showRefreshLoadingIndicator];
  //ToDo
}


-(BOOL)onlineOrShowError:(BOOL)showAlertIfNeeded{
  
  BOOL online = [self.mYMobiPaperLib areWeConnectedToInternet];
  
  if(!online&&showAlertIfNeeded)
  {
    [self showError:@"OFFLINE" message:@"Contenido del diario inalcanzable. Actualice la pantalla mas tarde."];
  }
  else{
    NSLog(@"onlineOrShowError NI err||offline");
  }
  
  self.offline_imgvw.hidden=online;
  self.offline_lbl.hidden=online;
  //if(!online) [self hideLoadingIndicator];
  
  return online;
}

-(BOOL)checkAndShowError{
  NSError*err=[mYMobiPaperLib getLasError];
  if(err==nil )
    return NO;
  [self showError:@"Aviso" message:@"Ha ocurrido un error. Actualice la pantalla mas tarde."];
  return YES;
  
}
  
-(void)showError:(NSString*)title message:(NSString*)message{
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
  [alert show];
  alert=nil;

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
  self.welcome_imgvw.hidden = NO;
  self.welcome_indicator.hidden = NO;
  [self.welcome_indicator startAnimating];
  [self showRefreshLoadingIndicator];
}


-(void) hideLoadingIndicator{
  self.loading_indicator.hidden = YES;
  [self.loading_indicator stopAnimating];
  
  [self hideRefreshLoadingIndicator];
  
  self.welcome_imgvw.hidden = YES;
  self.welcome_indicator.hidden = YES;
  [self.welcome_indicator stopAnimating];
  
  self.logo_imgvw_alpha.hidden = YES;
 
}
-(void) hideRefreshLoadingIndicator{
  btnRefreshClick.hidden=NO;
  btnRefreshClick.enabled=YES;
  self.refresh_loading_indicator.hidden = YES;
  [self.refresh_loading_indicator stopAnimating];
}

//YMobiPaperDelegate implementation
- (void) requestSuccessful:(id)data message:(NSString*)message{
  
  NSLog(@"MainViewController::requestSuccesfull message: %@", message);

  [self hideLoadingIndicator];
  
}

- (void) requestFailed:(id)error message:(NSString*)message{
  [self hideLoadingIndicator];
  [self showMessage:@"Ha ocurrido un error. Actualice la pantalla."];
}

-(void)showMessage:(NSString*)message{
  NSInteger top=50;
  if(sectionId!=nil)
  {
    top=80;
  }
  
  [[[iToast makeText:message] setGravity:iToastGravityTop offsetLeft:0 offsetTop:top] show];

}

// UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  //ToDo: mostrar algo sif necessary.
  [self hideLoadingIndicator];
  
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
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
