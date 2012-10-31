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

@synthesize mainUIWebView, bottomUIView, loading_indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.mainUIWebView.delegate = self;
  self.mainUIWebView.hidden = NO;
  
  // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.bottomUIView=nil;
  self.mainUIWebView=nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

-(void)loadClasificados:(NSURL *)url{
  
  [self onLoading:YES];
  NSString *uri = [url absoluteString];
  if([self.mScreenManager clasificadosExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getClasificados:uri useCache:YES error:&err];
    [self setHTML:data url:uri webView:self.mainUIWebView];
    return;
  }
  [self loadUrl:uri useCache:NO];
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache {
  [self onLoading:YES];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getClasificados:url useCache:useCache error:&err];
    
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
      
      [self setHTML:data url:url webView:self.mainUIWebView];
      
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
}

- (void)webView:(UIWebView*)sender zoomingEndedWithTouches:(NSSet*)touches event:(UIEvent*)event
{
	NSLog(@"finished zooming");
}

- (void)webView:(UIWebView*)sender tappedWithTouch:(UITouch*)touch event:(UIEvent*)event
{
	NSLog(@"tapped");
  [self singleTapWebView];
}

- (void)singleTapWebView {
  //self.bottomUIView.hidden = !self.bottomUIView.hidden;
  
  if([self.bottomUIView isHidden]==NO)
    [UIView animateWithDuration:.5
                     animations: ^ {
                       [self.bottomUIView setAlpha:0];
                     }
                     completion: ^ (BOOL finished) {
                       self.bottomUIView.hidden = YES;
                     }];
  else if([self.bottomUIView isHidden]==YES)
  {
    [self.bottomUIView setAlpha:0];
    self.bottomUIView.hidden = NO;
    [UIView animateWithDuration:.5
                     animations: ^ {
                       [self.bottomUIView setAlpha:1];
                     }
                     completion: ^ (BOOL finished) {
                       //self.bottomUIView.hidden = YES;
                     }];
  }
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
  [self changeFontSize:0];
  [self onLoading:NO];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  return NO;
}


@end
