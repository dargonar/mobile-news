//
//  MainViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MainViewController.h"
#import "iToast.h"

@implementation MainViewController
@synthesize mainUIWebView, mYMobiPaperLib, myNoticiaViewController, refresh_loading_indicator, btnRefreshClick;

static MainViewController *sharedInstance = nil;
NSString *sectionId = nil;
BOOL cacheCleaned = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
  
  /*start = [NSDate date];
  NSLog(@"MainViewController::initWirhNibName date:[%@]", start);*/
  self.mYMobiPaperLib = [[YMobiPaperLib alloc] init];
  self.mYMobiPaperLib.delegate = self;
  
  sharedInstance=self;
  return self;
}

+(MainViewController *)sharedInstance{
  return sharedInstance;
}

-(void)loadSectionNews:(NSURL*)rawURL{
  sectionId = [rawURL host] ;
  if([sectionId isEqualToString:@"0"])
  {
    sectionId=nil;
    [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST _webView:mainUIWebView tag:MSG_GET_MAIN force_load:NO];
  }
  else
  {
    [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeSectionNews queryString:sectionId xsl:XSL_PATH_SECTION_LIST _webView:mainUIWebView tag:MSG_GET_SECTION_LIST force_load:NO];
  }
}

- (IBAction) btnOptionsClick: (id)param{
  [app_delegate showSideMenu];
}

- (IBAction) btnRefreshClick: (id)param{
  [self showLoadingIndicator];
  if(sectionId==nil)
  {
    [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST _webView:mainUIWebView tag:MSG_GET_MAIN force_load:YES];
  }
  else{
    [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeSectionNews  queryString:sectionId xsl:XSL_PATH_SECTION_LIST _webView:mainUIWebView tag:MSG_GET_SECTION_LIST force_load:NO];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
  iToastSettings *theSettings = [iToastSettings getSharedSettings];
  theSettings.duration = 2500;
  
  [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST _webView:mainUIWebView tag:MSG_GET_MAIN force_load:NO];
  
  [self loadNoticiaView];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) showLoadingIndicator{
  btnRefreshClick.hidden=YES;
  btnRefreshClick.enabled=NO;
  self.refresh_loading_indicator.hidden = NO;
  [self.refresh_loading_indicator startAnimating];
}
-(void) hideLoadingIndicator{
  btnRefreshClick.hidden=NO;
  btnRefreshClick.enabled=YES;
  self.refresh_loading_indicator.hidden = YES;
  [self.refresh_loading_indicator stopAnimating];
  
}
//YMobiPaperDelegate implementation
- (void) requestSuccessful:(id)data message:(NSString*)message{
  if(sectionId==nil)
  {
    //[[[iToast makeText:message] setGravity:iToastGravityTop offsetLeft:0 offsetTop:50] show];
    //Limpiamos la cache un poquito solo la primera vez que traemos.
    if(cacheCleaned==NO && [((NSString*)data) isEqualToString:MSG_UPD_MAIN]==NO)
    {
      cacheCleaned=YES;
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.mYMobiPaperLib cleanCache];
      });
      //Luego de limpiar llamamos para que se cachee el menu de secciones.
      [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeSections queryString:nil xsl:nil _webView:nil tag:MSG_GET_SECTIONS force_load:NO];
    }
  }
  else{
    //[[[iToast makeText:message] setGravity:iToastGravityTop offsetLeft:0 offsetTop:8] show];
  }
  [self hideLoadingIndicator];
  
}

- (void) requestFailed:(id)error message:(NSString*)message{
  [self hideLoadingIndicator];
  
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
    
    
    [self.mYMobiPaperLib loadHtml:YMobiNavigationTypeNews queryString:[url host] xsl:XSL_PATH_NEWS _webView:self.myNoticiaViewController.mainUIWebView];
    
    NSLog(@"webView: DESPUES de cargar Noticia");

    return NO;
  }
  return YES;
  
}

-(void) loadNoticiaView{
  self.myNoticiaViewController= [[NoticiaViewController alloc]
                                 initWithNibName:@"NoticiaViewController" bundle:[NSBundle mainBundle]];
  self.myNoticiaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  
}


@end
