//
//  MassaViewController.m
//  Massa
//
//  Created by Davo on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MassaViewController.h"
#import "HTMLGenerator.h"
#import "CryptoUtil.h"
#import "SqliteCache.h"

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)

@implementation MassaViewController

@synthesize webView;
@synthesize tabBar;
@synthesize label;
@synthesize loading;
@synthesize msgerror;
@synthesize  btnRight, btnLeft, viewLoadingBack;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*
 /

/
*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

  //Las urls de los botones
  urls = [[NSArray alloc] initWithObjects:
                      	@"http://www.andigital.com.ar/dm_rss_mainstream.php?peto=1", 
                      	@"http://www.andigital.com.ar/dm_rss_mainstream.php?peto=2", 
                      	@"http://www.andigital.com.ar/dm_rss_mainstream.php?peto=3", 
                      	@"http://www.andigital.com.ar/dm_rss_mainstream.php?peto=4", 
                      	@"http://www.andigital.com.ar/dm_rss_mainstream.php?peto=5", 
                       	nil];
  
  NSLog(@"Len : %d", [urls count]);
  
  //theview.hidden = NO;
  viewLoadingBack.hidden = YES;
  loading.hidden = YES;
  label.hidden=YES;
  webView.hidden=NO;
  
	//Somos el handler para los dos controles
  tabBar.delegate = self;
	webView.delegate = self;
  
	[tabBar setSelectedItem: [tabBar.items objectAtIndex:0]];
  
  [self loadHtml: [urls objectAtIndex:0]];
  NSLog(@"Len2 : %d", [urls count]);  
  [super viewDidLoad];
}

-(void)loadHtml:(NSString *)path {
  NSData   *data     = nil;
  NSString *mimeType = nil;
  
  NSArray  *cache = [[SqliteCache defaultCache] get:path];
  if(cache) {
    data     = [cache objectAtIndex:0];
    mimeType = [cache objectAtIndex:1];
  }
  else {
    NSString *html = [self gethtml:path];
    data     = [NSData dataWithBytes:[html UTF8String] length:[html length]+1];
    mimeType = @"text/html";
    [[SqliteCache defaultCache] set:path data:data mimetype:mimeType];
  }
  
  [webView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:nil];
}

-(NSString *)gethtml:(NSString *)path {

  NSString *xml = [NSString stringWithContentsOfURL:[NSURL URLWithString:path] encoding:NSUTF8StringEncoding error:nil];
  NSString* path_xslt = [[NSBundle mainBundle] pathForResource:@"test_xsl"  ofType:@"xsl"];
  
  HTMLGenerator *generator = [[HTMLGenerator alloc] init];
  NSString *html = [generator generate:xml xslt_file:path_xslt];
  return html;
}


//Eventos del webview 
- (void)webViewDidFinishLoad:(UIWebView *)theview {
  NSLog(@"didFinish: %@; stillLoading:%@", [[webView request]URL],
        (webView.loading?@"NO":@"YES"));

  
  theview.hidden = NO;
  viewLoadingBack.hidden = YES;
  loading.hidden = YES;
  label.hidden=YES;
  
//  if( contains( [self.webView.request mainDocumentURL] , @"/view"))
  NSURL* url = [self.webView.request mainDocumentURL];
  
  if([ [url absoluteString] rangeOfString: @"/view" ].location != NSNotFound)
  {
   	self.btnRight.hidden = NO;
    self.btnLeft.hidden = NO;
  }
  else {
    self.btnRight.hidden = YES;
    self.btnLeft.hidden = YES;
  }

}

- (IBAction) btnRightClick: (id)param{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leer más tarde"
                                                  message:@"La noticia fue agregada a la lista de noticias a leer más tarde."
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil];
  [alert show];
  [alert release];
}

- (IBAction) btnLeftClick: (id)param{
	[webView goBack];
}

- (void)webViewDidStartLoad:(UIWebView *)theview {
//  msgerror.hidden = YES;
// 	webView.hidden = YES;
//
//  loading.hidden = NO;
//  viewLoadingBack.hidden = NO;
//  label.hidden   = NO;  
}

- (void)webView:(UIWebView *)theview didFailLoadWithError:(NSError *)error {
//  msgerror.hidden = NO;
//
// 	webView.hidden = YES;
//  loading.hidden = YES;
//  viewLoadingBack.hidden = YES;
//  label.hidden   = YES;  
  
}

//Handler de clicks en tabbar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
  NSLog(@"Len3: %d", [urls count]);  
  //[webView loadRequest: [self requestFor: [urls objectAtIndex:item.tag]]];  
  //[webView loadRequest:[self requestFor:@"/"]];  
  //NSLog(@"Len : %d", [urls count]);
  [self loadHtml:[urls objectAtIndex:item.tag]];
}

//Arma los requests para url en texto
- (NSURLRequest*) requestFor: (NSString*)location {
  //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.6:8090%@",location]];
  //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8095%@",location]];
  //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://testsdavento.appspot.com%@",location]];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",location]];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  return urlRequest;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
