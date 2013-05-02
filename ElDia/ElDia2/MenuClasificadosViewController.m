//
//  MenuClasificadosViewController.m
//  ElDia
//
//  Created by Davo on 11/9/12.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MenuClasificadosViewController.h"
#import "ErrorBuilder.h"
#import "Utils.h"
#import "AppDelegate.h"
@interface MenuClasificadosViewController ()

@end

@implementation MenuClasificadosViewController

@synthesize mainUIWebView, loading_indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      NSString *clasificadosNibName   = @"MenuClasificadosViewController";
      if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        clasificadosNibName  = @"MenuClasificadosViewController_iPad"; // NO EXISTE!
      }
      self.clasificadosViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

  [[self mainUIWebView] setScalesPageToFit:YES];
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"menu_clasificados" ofType:@"html"];
  NSData*htmlData=  [NSData dataWithContentsOfFile:filePath];
  [self setHTML:htmlData url:nil webView:self.mainUIWebView];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self rotateHTML];
}


-(void) rotateHTML{
  if([app_delegate isiPad])
    return;
  return;
  NSString *viewportWidth = @"";
  NSString *viewportInitScale = @"";
  NSString *viewportMaxScale = @"";
  
  viewportWidth = @"320";
  viewportInitScale = @"1.0";
  viewportMaxScale = @"1.0";
  if([app_delegate isLandscape]){
    //viewportWidth = @"480";
    viewportInitScale = @"1.5";
    viewportMaxScale = @"1.5";
    
  }
  
  //document.body.style.width = '%@px';
  NSString *jsString = [[NSString alloc] initWithFormat:@"metayi = document.querySelector('meta[name=viewport]'); metayi.setAttribute('content','width=%@; minimum-scale=%@;initial-scale=%@; maximum-scale=%@; user-scalable=no;');",viewportWidth, viewportInitScale, viewportInitScale, viewportMaxScale  ];
  
  NSLog(@"%@",jsString);
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  [self.mainUIWebView reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) btnBackClick: (id)param{
  [[app_delegate navigationController] popViewControllerAnimated:YES];
}

// HACK: Estaba comentado
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

/* rotation handling */
- (BOOL) shouldAutorotate
{
  return YES; //[app_delegate isiPad];
}

-(NSUInteger)supportedInterfaceOrientations
{
  //return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft;
  //return UIInterfaceOrientationMaskAll;
  return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
  
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait ;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
  [self rotateHTML];
  //[mainUIWebView reload];
}

-(void) onLoading:(BOOL)started{
  self.loading_indicator.hidden = !started;
  if(started)
    [self.loading_indicator startAnimating ];
  else
    [self.loading_indicator stopAnimating ];
  
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  if(![app_delegate isiPad])
  {
    [self rotateHTML];
  }
  [self onLoading:NO];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  
  NSURL* url = [request URL];
  if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"servicio"])
  {
    [app_delegate loadSectionNews:url];
    //ToDo -> llamar al main view
    return NO;
  }
  else
    if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"clasificados"])
    {
      [app_delegate.navigationController pushViewController:self.clasificadosViewController animated:YES];
      
      [self.clasificadosViewController loadClasificados:url];

      return NO;
    }
  return YES;
  
}

@end
