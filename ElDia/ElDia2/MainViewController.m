//
//  MainViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MainViewController.h"
#import "RegexKitLite.h"

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
  
  /*
  char   *searchString = " encabezado por la titular de dicha comisi&oacute;n, 123 12 1<p style='text-align: justify;'  > <strong>Fernanda Raverta</strong>; el secretario de DDHH bonaerense, <strong>Guido Carlotto</strong>, y el presidente del Equipo Argentino de Antropolog&iacute;a Forense, <strong>Luis Fonderbrider</strong>.</span></span><p style=\"text-align: justify;\"><span style=\"font-family: trebuchet ms,geneva;\"><span style=\"font-size: small;\">&ldquo;&Eacute;sta es una campa&ntilde;a que se realiza en toda Latinoam&eacute;rica, con la cual el equipo de antrop&oacute;logos forenses, a partir de las muestras de sangre que familiares de las v&iacute;ctimas han dado, pudieron identificar y devolver su identidad a personas que fueron asesinadas, para que sus familias pudieran procesar el duelo&rdquo;, explic&oacute; Raverta.</span></span><p style=\"text-align: justify;\"><span style=\"font-family: trebuchet ms,geneva;\"><span style=\"font-size: small;\">Por su parte, Carlotto valor&oacute; la posibilidad de &ldquo;trabajar en conjunto con la C&aacute;mara de Diputados y con esta nueva juventud que aflora con alegr&iacute;a, con esperanza y con la necesidad de continuar construyendo un camino de memoria, verdad y justicia&rdquo;, al tiempo que anticip&oacute; que en los pr&oacute;ximos d&iacute;as se firmar&aacute; un decreto interministerial para unificar el trabajo del Gobierno bonaerense sobre la tortura, vejaciones y malos tratos en las c&aacute;rceles. (<strong>ANDigital</strong>)</span></span>]]></news:content>";
  NSString *subjectString = [NSString stringWithUTF8String:searchString];
  NSString   *regexString  =@"(?<=<)([^/>]+)(\\s(style|class)=['\"][^'\"]+?['\"])([^/>]*)(?=/?>|\\s)";
  NSUInteger  line         = 0UL;
  NSLog(@"searchString: '%@'", subjectString);
  NSLog(@"regexString : '%@'", regexString);
  for(NSString *matchedString in [subjectString componentsMatchedByRegex:regexString]) {
    NSLog(@"--)MATCHED: %lu: %lu '%@'", (u_long)++line, (u_long)[matchedString length], matchedString);
  }
  */
  [self.mYMobiPaperLib loadHtml:YMobiNavigationTypeMain queryString:nil xsl:MAIN_XSL_PATH _webView:mainUIWebView];
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
  NSLog(@"webView event");
  //validar URL
  if (UIWebViewNavigationTypeLinkClicked == navigationType)
  {
    
    NSURL* url = [request URL];
    //[self.mainUIWebView loadHTMLString:[self.mYMobiPaperLib getUrl:YMobiNavigationTypeNews queryString:[url lastPathComponent]] baseURL:nil];
    
    if (self.myNoticiaViewController == nil) {
      [self loadNoticiaView];      
    }
    
    NSLog(@"webView: ANTES de cargar Noticia");
    //webAddress.text = [url absoluteString];
    
    
    [app_delegate.navigationController pushViewController:myNoticiaViewController animated:YES];
    
    //[self.mYMobiPaperLib loadHtml:YMobiNavigationTypeNews queryString:[url lastPathComponent] xsl:NEWS_XSL_PATH _webView:self.myNoticiaViewController.mainUIWebView];
    [self.mYMobiPaperLib loadHtml:YMobiNavigationTypeNews queryString:@"1_161794" xsl:NEWS_XSL_PATH _webView:self.myNoticiaViewController.mainUIWebView];
    
    
    //[self.mYMobiPaperLib loadHtml:YMobiNavigationTypeNews queryString:[url lastPathComponent] xsl:NEWS_XSL_PATH _webView:self.mainUIWebView];
    
    NSLog(@"webView: DESPUES de cargar Noticia");

    return NO;
  }
  return YES;
  
}


@end
