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

@implementation MainViewController
@synthesize mainUIWebView, mYMobiPaperLib, myNoticiaViewController, refresh_loading_indicator, btnRefreshClick, loading_indicator, logo_imgvw_alpha,
            welcome_imgvw, welcome_indicator;

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
  
  sharedInstance=self;
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
  iToastSettings *theSettings = [iToastSettings getSharedSettings];
  theSettings.duration = 2500;
  
  bool firstTimeUse = [self isFirstTimeUse];
  if(firstTimeUse)
    [self showWelcomeLoadingIndicator];
  
  if(!firstTimeUse)
    [self showMainLoadingIndicator];
 
  [self loadLastKnownIndex];
  
  [self loadIndex:YES];
   
  [self loadNoticiaView];
  
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
  sectionId = [rawURL host] ;
  [self showMainLoadingIndicator];
  if([sectionId isEqualToString:@"0"])
  {
    sectionId=nil;
    [self loadIndex:NO];
    NSLog(@"MainViewController::loadSectionNews loadIndex POST Call");
  }
  else
  {
    [self loadSection:NO];
    NSLog(@"MainViewController::loadSectionNews loadSection POST Call");
  }
}

- (IBAction) btnOptionsClick: (id)param{
  [app_delegate showSideMenu];
}

- (IBAction) btnRefreshClick: (id)param{
  //self performSelectorOnMainThread:<#(SEL)#> withObject:<#(id)#> waitUntilDone:<#(BOOL)#>
  
  
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
  
  NSLog(@"MainViewController::setHtmlToView ME llamaron!!!");
  NSString *dirPath = [[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [self.mainUIWebView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:dirURL];
  
  if(stop_loading_indicators)
  {
    [self hideLoadingIndicator];
  }
  data = nil;
  dirPath=nil;
  dirURL=nil;

}

-(void)loadSection:(BOOL)force_load{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSData* data=[self.mYMobiPaperLib getHtmlAndConfigure:YMobiNavigationTypeSectionNews queryString:sectionId xsl:XSL_PATH_SECTION_LIST tag:MSG_GET_SECTION_LIST force_load:force_load];
    // tell the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setHtmlToView:data stop_loading_indicators:YES];
      data=nil;
    });
  });
  
}

-(void)loadIndex:(BOOL)force_load{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSData* data=[self.mYMobiPaperLib getHtmlAndConfigure:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST tag:MSG_GET_MAIN force_load:force_load];
    // tell the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setHtmlToView:data stop_loading_indicators:YES];
      
      if(cacheCleaned==NO )
      {
        cacheCleaned=YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [self.mYMobiPaperLib cleanCache];
          [self.mYMobiPaperLib getHtml:YMobiNavigationTypeSections queryString:nil xsl:XSL_PATH_SECTIONS];
        });
        NSLog(@"MainViewController::loadindex ");
        
      }
      data=nil;
      
    });
  });
}

-(void)loadLastKnownIndex{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSData* data=[self.mYMobiPaperLib getChachedDataAndConfigure:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST tag:MSG_GET_MAIN fire_event:NO];
    if(data==nil)
      return;
    // tell the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setHtmlToView:data  stop_loading_indicators:YES];
      [self showRefreshLoadingIndicator];
      data=nil;
    });
  });
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
  
  bool firstTimeUse = [self isFirstTimeUse];
  if(firstTimeUse)
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

    //[self.mainUIWebView loadHTMLString:[self.mYMobiPaperLib getUrl:YMobiNavigationTypeNews queryString:[url lastPathComponent]] baseURL:nil];
    
    if (self.myNoticiaViewController != nil) {
      [self.myNoticiaViewController loadBlank];
    }
    if (self.myNoticiaViewController == nil) {
      [self loadNoticiaView];      
    }
    
    [app_delegate.navigationController pushViewController:myNoticiaViewController animated:YES];
    /*
    NSURL* _url = [[NSURL alloc] initWithString:@"video://http://www.youtube.com/watch?v=e3fsrQmHmfA"];
    NSLog(@"MainViewController::linkClicked 1: %@", [_url lastPathComponent]);
    NSLog(@"MainViewController::linkClicked 2: %@", [_url host]); // OK
    NSLog(@"MainViewController::linkClicked 3: %@", [_url pathComponents]);
    NSLog(@"MainViewController::linkClicked 4: %@", [_url query]);
    NSLog(@"MainViewController::linkClicked 5: %@", [_url absoluteString]);
    NSLog(@"MainViewController::linkClicked 6: %@", [_url scheme]);*/
    
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
