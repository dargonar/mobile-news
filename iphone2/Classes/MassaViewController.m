//
//  MassaViewController.m
//  Massa
//
//  Created by Davo on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MassaViewController.h"

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
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

  //Las urls de los botones
  urls 	= [[NSArray alloc] initWithObjects: 
                      	@"/", 
                       	@"/m/secciones", 
                       	@"/m/suplementos",
                       	@"/m/servicios",
                       	@"/m/perfil",
                       	nil];
  
	//Somos el handler para los dos controles
  tabBar.delegate = self;
	webView.delegate = self;
  
	[tabBar setSelectedItem: [tabBar.items objectAtIndex:0]];
  //[tabBar setSelectedItem]
  
  [webView loadRequest: [self requestFor: [urls objectAtIndex:0]]];
  [super viewDidLoad];
}

//Eventos del webview 
- (void)webViewDidFinishLoad:(UIWebView *)theview {
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
  msgerror.hidden = YES;
 	webView.hidden = YES;

  loading.hidden = NO;
  viewLoadingBack.hidden = NO;
  label.hidden   = NO;  
}

- (void)webView:(UIWebView *)theview didFailLoadWithError:(NSError *)error {
  msgerror.hidden = NO;

 	webView.hidden = YES;
  loading.hidden = YES;
  viewLoadingBack.hidden = YES;
  label.hidden   = YES;  
  
}

//Handler de clicks en tabbar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
  
  [webView loadRequest: [self requestFor: [urls objectAtIndex:item.tag]]];  
  
}

//Arma los requests para url en texto
- (NSURLRequest*) requestFor: (NSString*)location {
  //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.6:8090%@",location]];
  //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8095%@",location]];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://testsdavento.appspot.com%@",location]];
  NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
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
