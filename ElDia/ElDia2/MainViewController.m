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
#import "ScreenManager.h"
#import "DiskCache.h"


@implementation MainViewController
@synthesize mainUIWebView, mYMobiPaperLib, myNoticiaViewController, refresh_loading_indicator, btnRefreshClick, loading_indicator, logo_imgvw_alpha,
            welcome_imgvw, welcome_indicator, offline_imgvw, offline_lbl, currentUrl;

static MainViewController *sharedInstance = nil;
NSString *sectionId = nil;
BOOL cacheCleaned = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
  
  self.mYMobiPaperLib = [[YMobiPaperLib alloc] init];
  self.mYMobiPaperLib.delegate = self;

  sharedInstance = nil;
  sectionId = nil;
  cacheCleaned = NO;
  sharedInstance=self;
  
  return self;
}
/*
+ (MainViewController *) sharedInstance
{
  static MainViewController *sharedInstance = NULL;
  @synchronized(self)
  {
    if(sharedInstance == NULL)
      sharedInstance = [[MainViewController alloc] init];
  }
  
  return sharedInstance;
}
*/

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
  iToastSettings *theSettings = [iToastSettings getSharedSettings];
  theSettings.duration = 2500;
  /*
  bool firstTimeUse = [self isFirstTimeUse];
  if(firstTimeUse)
    [self showWelcomeLoadingIndicator];
  else
    [self showMainLoadingIndicator];
 
  [self loadLastKnownIndex];
  
  [self loadIndex:YES];
   
  [self loadNoticiaView];
  */
  
  [self setCurrentUrl:@"section://main"];
  ScreenManager *mgr = [[ScreenManager alloc] init];
  NSArray *arr = [mgr getSection:self.currentUrl  useCache:YES];
  
  NSData  *data = [arr objectAtIndex:0];
  NSArray *imgs = [arr objectAtIndex:1];
  
  NSString *dirPath = [[DiskCache defaultCache] getCacheFolder] ;//[[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [mainUIWebView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:dirURL];
  
  [app_delegate downloadImages:imgs obj:self request_url:self.currentUrl];
  
  [self hideLoadingIndicator];
  
  mgr = nil;

  
  NSLog(@"MainViewController::viewDidLoad termina");
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
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

// Aqui me llaman para cargar noticias de una seccion. Eventualmente puede ser la seccion principal, o no-seccion.
-(void)loadSectionNews:(NSURL*)rawURL{
  
  sectionId = [[rawURL host] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]] ;
  
  [self showMainLoadingIndicator];
  
  if([sectionId isEqualToString:@"0"])
  {
    sectionId=nil;
    [self loadIndex:NO];
    //NSLog(@"MainViewController::loadSectionNews loadIndex POST Call");
  }
  else
  {
    [self loadSection:NO];
    //NSLog(@"MainViewController::loadSectionNews loadSection POST Call");
  }
}

- (IBAction) btnOptionsClick: (id)param{
  [app_delegate showSideMenu];
}

- (IBAction) btnRefreshClick: (id)param{

  
  [self showRefreshLoadingIndicator];
  if(sectionId==nil)
  {
    [self loadIndex:YES];
  }
  else{
    [self loadSection:YES];
  }
}

-(void)setHtmlToView:(NSData*)data stop_loading_indicators:(BOOL)stop_loading_indicators{
  
  if(stop_loading_indicators)
  {
    [self hideLoadingIndicator];
  }
  
  if(data==nil){
    // [self onlineOrShowError:YES];
    return;
  }
  NSLog(@"MainViewController::setHtmlToView ME llamaron!!!");
  NSString *dirPath = [[DiskCache defaultCache] getCacheFolder] ;//[[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [self.mainUIWebView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:dirURL];

  [self.mainUIWebView loadData:nil MIMEType:nil textEncodingName:nil baseURL:nil];
  
  
  data = nil;
  dirPath=nil;
  dirURL=nil;

}

-(void)onImageDownloaded:(MobiImage*)mobi_image url:(NSString*)url{
  
  if(self.currentUrl!=url)
    return;
  
  NSString *jsString  = [NSString stringWithFormat:@"document.getElementById('%@').style.backgroundImage = ''; document.getElementById('%@').style.backgroundImage = 'url(%@)';"
                         , mobi_image.local_uri
                         , mobi_image.local_uri
                         , [NSString stringWithFormat:@"i_%@", mobi_image.local_uri ] ];
  
  NSLog(@" llego imigi: %@", mobi_image.local_uri);
  
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  
  jsString=nil;
  return;
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

-(void)loadSection:(BOOL)force_load{
  
  [self onlineOrShowError:YES];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    __block NSData* data=[self.mYMobiPaperLib getHtmlAndConfigure:YMobiNavigationTypeSectionNews queryString:sectionId xsl:XSL_PATH_SECTION_LIST tag:MSG_GET_SECTION_LIST force_load:force_load];
    
    // tell the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      if(data==nil)
      {
        [self checkAndShowError];
        [self hideLoadingIndicator];
        return;
      }
      [self setHtmlToView:data stop_loading_indicators:YES];
      data=nil;
    });
  });
  
}

-(void)loadIndex:(BOOL)force_load{
  
  [self onlineOrShowError:YES];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    __block NSData* data=[self.mYMobiPaperLib getHtmlAndConfigure:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST tag:MSG_GET_MAIN force_load:force_load];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      if(data==nil)
      {
        [self checkAndShowError];
        [self hideLoadingIndicator];
        return;
      }
      
      [self setHtmlToView:data stop_loading_indicators:YES];
      
      if(cacheCleaned==NO )
      {
        cacheCleaned=YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [self.mYMobiPaperLib cleanCache];
          [self.mYMobiPaperLib getHtml:YMobiNavigationTypeSections queryString:nil xsl:XSL_PATH_SECTIONS];
        });
        
      }
      data=nil;
      
      //[[[iToast makeText:@"Marky... chupame el moco!"] setGravity:iToastGravityCenter offsetLeft:0 offsetTop:50] show];

    });
  });
}

-(void)loadLastKnownIndex{
  NSData* data=[self.mYMobiPaperLib getChachedDataAndConfigure:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST tag:MSG_GET_MAIN fire_event:NO];
  if(data!=nil)
    [self setHtmlToView:data  stop_loading_indicators:YES];
  [self hideLoadingIndicator];
  [self showRefreshLoadingIndicator];
  data=nil;
  /*
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSData* data=[self.mYMobiPaperLib getChachedDataAndConfigure:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST tag:MSG_GET_MAIN fire_event:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
      if(data!=nil)
        [self setHtmlToView:data  stop_loading_indicators:YES];
      [self showRefreshLoadingIndicator];
      data=nil;
    });
  });
   */
}


-(bool)isFirstTimeUse{
  if([ConfigHelper getSettingValue:CFG_FIRSTTIME]==nil)
  {
    return YES;
  }
  return NO;
}

-(void)firstTimeUseGone{
  [ConfigHelper setSettingValue:CFG_FIRSTTIME value:@"NO"];
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
  
  if([self isFirstTimeUse]==YES)
  {
    [self firstTimeUseGone];
  }
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
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  //[webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
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
