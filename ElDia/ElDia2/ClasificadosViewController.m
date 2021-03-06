//
//  ClasificadosViewController.m
//  ElDia
//
//  Created by Lion User on 30/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "ClasificadosViewController.h"
#import "ConfigHelper.h"
#import "ErrorBuilder.h"
#import "Utils.h"
#import "AppDelegate.h"

@interface ClasificadosViewController ()

@end

@implementation ClasificadosViewController

@synthesize mainUIWebView, bottomUIView, loading_indicator, childClasificadosViewController;

NSData*notLoadedData = nil;
BOOL mViewDidLoad=NO;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      notLoadedData = nil;
      mViewDidLoad = NO;
      
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.

  self.primaryUIWebView= self.mainUIWebView;
  
  self.mainUIWebView.delegate = self;
  self.mainUIWebView.hidden = NO;
  [[self mainUIWebView] setScalesPageToFit:NO];
  if(notLoadedData != nil)
  {
    [self setHTML:notLoadedData url:nil webView:self.mainUIWebView];
    notLoadedData=nil;
  }
  mViewDidLoad=YES;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.bottomUIView=nil;
  self.mainUIWebView=nil;

}

-(void)positionate{
  [self positionate:NO];
}

-(void)positionate:(BOOL)forzar{
  
  UIDeviceOrientation deviceOrientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;

//  [self positionateAdNoticiaScreen:deviceOrientation];
  [self positionateAdOtherScreen:[UIApplication sharedApplication].statusBarOrientation];
  
  NSInteger  width=self.view.frame.size.width;
  NSInteger  height=self.view.frame.size.height;
  
  
  if (UIDeviceOrientationIsLandscape(deviceOrientation))
  {
    if ([app_delegate isiPad]) {
      // x y width height
      self.mainUIWebView.frame=CGRectMake(256, 44, 1024-256, height-44-[self adHeight]);
    }
    else{
      self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44-[self adHeight]);
    }

  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation))
  {
    if ([app_delegate isiPad]) {
      // x y width height
      self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44-[self adHeight]);
          }
    else{
      self.mainUIWebView.frame=CGRectMake(0, 44, width, height-44-[self adHeight]);
    }
  }
  [self zoomToFit];
  
}

// HACK: Estaba comentado
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

/* rotation handling */
- (BOOL) shouldAutorotate
{
  return YES; 
}

-(NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
  
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait ;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  [self positionate];
}

/* **** */



-(void)changeFontSize:(NSInteger)delta{
  
  CGFloat textFontSize = 1.0;
  NSString *_textFontSize = [ConfigHelper getSettingValue:CFG_CLASIFICADOS_FONTSIZE];
  if(_textFontSize!=nil)
  {
    textFontSize = [_textFontSize floatValue];
  }
  bool fontChanged = NO;
  if(delta<0) {
    textFontSize = (textFontSize >= 1) ? textFontSize -0.05 : textFontSize;
    fontChanged=YES;
  }
  else
    if(delta>0) {
      textFontSize = (textFontSize < 2.6) ? textFontSize +0.05 : textFontSize;
      fontChanged=YES;
    }
    else
    {
      
    }
  
  NSString *jsString = [[NSMutableString alloc] initWithFormat:@"document.getElementById('clasificados_container').style.fontSize= '%fem';", textFontSize];
    
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  
  jsString=nil;
  if(fontChanged==YES)
  {
    [ConfigHelper setSettingValue:CFG_CLASIFICADOS_FONTSIZE value:[[NSString alloc] initWithFormat:@"%f", textFontSize]];
  }
  
}
- (IBAction) btnFontSizePlusClick: (id)param{
  [self changeFontSize:1];
}
- (IBAction) btnFontSizeMinusClick: (id)param{
  [self changeFontSize:-1];
  
}

- (IBAction) btnBackClick: (id)param{
  [[app_delegate navigationController] popViewControllerAnimated:YES];
}	

- (IBAction) btnShareClick: (id)param{
  
  if(![Utils areWeConnectedToInternet])
  {
    [self showMessage:@"No hay conexion de red.\nNo podemos desplegar el contenido solicitado." isError:YES];
    return;
  }
  /*
  NSURL *url = [NSURL URLWithString:self.noticia_url];
  
	SHKItem *item = [SHKItem URL:url title:[[NSString alloc] initWithFormat:@"%@ - ElDia.com.ar", self.noticia_title] ];
  
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
  
  [actionSheet showFromToolbar:self.navigationController.toolbar];
  */
}

-(void)loadBlank{
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
  self.bottomUIView.hidden = YES;
}

-(void)loadFarmacia:(NSURL *)url{
  
  self.mainUIWebView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
  [self loadBlank];
  [self onLoading:YES];
  NSString *uri = [url absoluteString];
  NSDate * date =[self.mScreenManager farmaciaDate:uri];
  if([self.mScreenManager farmaciaExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getFarmacia:uri useCache:YES error:&err];
    if(mViewDidLoad==NO)
      notLoadedData=data;
    else
      [self setHTML:data url:nil webView:self.mainUIWebView];
    
    if(![self isOld:date])
      return;
  }
  [self loadUrl:uri useCache:NO type:@"farmacia"];
}

-(void)loadCartelera:(NSURL *)url{
  
  self.mainUIWebView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
  [self loadBlank];
  [self onLoading:YES];
  NSString *uri = [url absoluteString];
  NSDate * date =[self.mScreenManager carteleraDate:uri];
  if([self.mScreenManager farmaciaExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getCartelera:uri useCache:YES error:&err];
    if(mViewDidLoad==NO)
      notLoadedData=data;
    else
      [self setHTML:data url:nil webView:self.mainUIWebView];
    
    if(![self isOld:date])
      return;
  }
  [self loadUrl:uri useCache:NO type:@"cartelera"];
}

-(void)loadFunebres:(NSURL *)url{
  
  self.mainUIWebView.dataDetectorTypes = UIDataDetectorTypeNone;
  [self loadBlank];
  [self onLoading:YES];
  NSString *uri = [url absoluteString];
  NSDate * date =[self.mScreenManager funebresDate:uri];
  if([self.mScreenManager funebresExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getFunebres:uri useCache:YES error:&err];
    if(mViewDidLoad==NO)
      notLoadedData=data;
    else
      [self setHTML:data url:nil webView:self.mainUIWebView];
    
    if(![self isOld:date])
      return;
  }
  [self loadUrl:uri useCache:NO type:@"funebres"];
}


-(void)loadMenuClasificados:(NSURL *)url{
    self.mainUIWebView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
  [self loadBlank];
  [self onLoading:YES];
  NSString *uri = [url absoluteString];
  NSDate * date =[self.mScreenManager menuClasificadosDate:uri];
  if([self.mScreenManager menuClasificadosExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getMenuClasificados:uri useCache:YES error:&err];
    if(mViewDidLoad==NO)
      notLoadedData=data;
    else
      [self setHTML:data url:nil webView:self.mainUIWebView];
    
    if(![self isOld:date])
      return;
  }
  [self loadUrl:uri useCache:NO type:@"menu_clasificados"];
}

-(void)loadClasificados:(NSURL *)url{
  self.mainUIWebView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
  [self loadBlank];
  [self onLoading:YES];
  NSString *uri = [url absoluteString];
  NSDate * date =[self.mScreenManager clasificadosDate:uri];
  if([self.mScreenManager clasificadosExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getClasificados:uri useCache:YES error:&err];
    if(mViewDidLoad==NO)
      notLoadedData=data;
    else
      [self setHTML:data url:nil webView:self.mainUIWebView];
    
    if(![self isOld:date])
      return;
  }
  [self loadUrl:uri useCache:NO type:@"clasificados"];
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache type:(NSString*)type{
  //[self onLoading:YES];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = nil;
    if([type isEqualToString:@"funebres"])
      data = [self.mScreenManager getFunebres:url useCache:useCache error:&err];
    else
      if([type isEqualToString:@"farmacia"])
        data = [self.mScreenManager getFarmacia:url useCache:useCache error:&err];
      else
        if([type isEqualToString:@"cartelera"])
          data = [self.mScreenManager getCartelera:url useCache:useCache error:&err];
        else
          if([type isEqualToString:@"clasificados"])
            data = [self.mScreenManager getClasificados:url useCache:useCache error:&err];
          else
            if([type isEqualToString:@"menu_clasificados"])
              data = [self.mScreenManager getMenuClasificados:url useCache:useCache error:&err];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      if(data==nil)
      {
        if([err code]==ERR_NO_INTERNET_CONNECTION)
        {
          [self showMessage:@"No hay conexion de red.\nNo podemos actualizar la aplicacion." isError:YES];
        }
        else
          [self showMessage:err.description isError:YES];
        [self onLoading:NO];
        return;
      }
      
      if(mViewDidLoad==NO)
        notLoadedData=data;
      else
        [self setHTML:data url:nil webView:self.mainUIWebView];
      
      data=nil;
      
      
    });
  });
}

-(void) onLoading:(BOOL)started{
  self.loading_indicator.hidden = !started;
  if(started)
    [self.loading_indicator startAnimating ];
  else
    [self.loading_indicator stopAnimating ];
  
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
  app_delegate.navigationController.navigationBar.hidden=YES;
  
  [self positionate];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  
  [self zoomToFit];
  

  [self changeFontSize:0];
  [self onLoading:NO];
  
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  NSLog(@"%@", error);
  [self onLoading:NO];
}

/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  NSLog(@" %@ ", [request.URL absoluteString]);
  if (UIWebViewNavigationTypeLinkClicked == navigationType && ![[request.URL absoluteString] hasPrefix:@"tel"])
    return NO;
  
  return YES;
}
 */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  
  NSURL* url = [request URL];
  if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"clasificados"])
  {
    [self loadChildScreen];
    [app_delegate.navigationController pushViewController:self.childClasificadosViewController animated:YES];
    
    [self.childClasificadosViewController loadClasificados:url];
//    NSLog(@" --------------------");
//    NSLog(@" -- url: %@", [url absoluteString]);
    [BaseMobiViewController trackClick:[url absoluteString]];
    return NO;
  }
  else
    if (UIWebViewNavigationTypeLinkClicked == navigationType && ![[request.URL absoluteString] hasPrefix:@"tel"])
    {
      [BaseMobiViewController trackClick:[url absoluteString]];
      return NO;
    }
    else{
      [[UIApplication sharedApplication] openURL:url];
      [BaseMobiViewController trackClick:[url absoluteString]];
    }
  
  return YES;
  
}

-(void)loadChildScreen{
  if(self.childClasificadosViewController!=nil)
    return;
  NSString *clasificadosNibName   = @"ClasificadosViewController";
  if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
    clasificadosNibName  = @"ClasificadosViewController_iPad"; // NO EXISTE!
  }
  self.childClasificadosViewController = [[ClasificadosViewController alloc] initWithNibName:clasificadosNibName bundle:nil];
}


@end
