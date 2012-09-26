//
//  MainViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController
@synthesize mainUIWebView, mYMobiPaperLib, myNoticiaViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
  
  //Somos el handler para los dos controles
  self.mYMobiPaperLib = [[YMobiPaperLib alloc] init];
  //self.mainUIWebView.delegate = self;
  
  return self;
}


- (IBAction) btnOptionsClick: (id)param{
  [app_delegate showSideMenu];
}

- (IBAction) btnRefreshClick: (id)param{
    
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  NSLog(@"viewDidLoad BEGIN");
  
  [self.mYMobiPaperLib loadHtml:YMobiNavigationTypeMain queryString:nil xsl:XSL_PATH_MAIN_LIST _webView:mainUIWebView];
  NSLog(@"viewDidLoad END");
  
  [self loadNoticiaView];
}

-(void) loadNoticiaView{
  self.myNoticiaViewController= [[NoticiaViewController alloc]
                                 initWithNibName:@"NoticiaViewController" bundle:[NSBundle mainBundle]];
  self.myNoticiaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  //self.myNoticiaViewController.delegate = self;

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// UIWebView Delegate

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




@end
