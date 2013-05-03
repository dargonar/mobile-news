//
//  BaseMobiViewController.m
//  ElDia
//
//  Created by Lion User on 25/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "BaseMobiViewController.h"

#import "AppDelegate.h"
#import "DiskCache.h"
#import "iToast.h"



@interface BaseMobiViewController ()

@end

@implementation BaseMobiViewController

@synthesize mScreenManager, currentUrl, primaryUIWebView, secondaryUIWebView, adUIWebView;

BOOL mIsIpad=NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Custom initialization
      
      mIsIpad = [app_delegate isiPad];
      
      self.mScreenManager = [[ScreenManager alloc] init];
      self.primaryUIWebView=nil;
      self.secondaryUIWebView=nil;
      self.adUIWebView = nil;
    }
  
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(onImageDownloaded:) 
                                               name:@"com.diventi.mobipaper.image_downloaded" 
                                             object:nil];
}

- (void)viewDidUnload
{
  [super viewDidUnload];

  [[NSNotificationCenter defaultCenter] removeObserver:self
                                               name:@"com.diventi.mobipaper.image_downloaded" 
                                             object:nil];

}

/*- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self positionateAd];
}
*/

-(void)initAd{
  //728x90  / 468x60 | 320x50 
  self.adUIWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320,50)];
  self.adUIWebView.tag = 0x1114;
  self.adUIWebView.hidden=YES;
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ad_dummy" ofType:@"html"];
  NSData*htmlData=  [NSData dataWithContentsOfFile:filePath];
  [self.adUIWebView loadData:htmlData
                    MIMEType:@"text/html"
                    textEncodingName:@"utf-8"
                    baseURL:[[DiskCache defaultCache] getFolderUrl]];
   [self.view addSubview:self.adUIWebView ];
  
}
-(void)positionateAd:(UIDeviceOrientation) deviceOrientation imInLandscape:(BOOL)imInLandscape{
  
  //UIDeviceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
  if(self.adUIWebView == nil)
    [self initAd];

  BOOL isVisible = YES;
  
  NSString* ad_size = @"320x50";
  if (UIDeviceOrientationIsLandscape(deviceOrientation)) // && !imInLandscape)
  {
    //[self positionateAdLandscape];
    if ([app_delegate isiPad]) {
      
      ad_size = @"468x60";
    }
    else{
      isVisible=NO;
    }
  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation)) // && imInLandscape)
  {
    //[self positionateAdPortrait];
    if ([app_delegate isiPad]) {
      ad_size = @"728x90";
    }
    else{
      self.adUIWebView.frame=CGRectMake(0, 430, 320, 480);
      ad_size = @"320x50";
    }
  }
  
  if(isVisible==NO)
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.adUIWebView.hidden=YES;
    });
    return;
  }
  
  __block NSString *jsString  = [NSString stringWithFormat:@"eplAD4M('%@')"
                                 , ad_size];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    self.adUIWebView.hidden=NO;
    [self.adUIWebView stringByEvaluatingJavaScriptFromString:jsString];
    jsString=nil;
    [self.view bringSubviewToFront:self.adUIWebView];
    
  });
  
}
/*
-(void)positionateAdLandscape{
  }

-(void)positionateAdPortrait{
  }
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*****/
- (void) setCurrentUrl:(id)_url
{
  self->currentUrl = _url;
  self.trackedViewName = _url; //@"About Screen";
}

-(void)showMessage:(NSString*)message isError:(BOOL)isError{
  if(isError)
    [[[iToast makeText:message] setGravity:iToastGravityCenter offsetLeft:0 offsetTop:0] show:iToastTypeWarning];
  else
    [[iToast makeText:message] setGravity:iToastGravityCenter offsetLeft:0 offsetTop:0];

}


-(void)configureToast{
  iToastSettings *theSettings = [iToastSettings getSharedSettings];
  theSettings.duration = 4000;
  //UIImage *warning_image = [UIImage imageNamed: @"warning.48x48.png"];
  UIImage *warning_image = [UIImage imageNamed: @"warning.hueco.48x48.png"];
  [theSettings setImage:warning_image forType:iToastTypeWarning];
}

-(BOOL)isOld:(NSDate*)date {
  if(date==nil)
    return YES;
  NSTimeInterval t= [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:date];
  if(t > (60*60*2))
    //if(t > 1)
    return YES;
  
  return NO;
}

-(void)setHTML:(NSData*)data url:(NSString*)url webView:(UIWebView*)webView{
  [webView  loadData:data
            MIMEType:@"text/html"
            textEncodingName:@"utf-8"
            baseURL:[[DiskCache defaultCache] getFolderUrl]];

  if(url!=nil)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSError *err;
      NSArray *mobi_images = [self.mScreenManager getPendingImages:url error:&err];
      NSLog(@" --BaseMobiViewController::setHTML url=[%@]",url);
      if (mobi_images != nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:url, @"url", nil];
      
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"com.diventi.mobipaper.download_images"
                object:mobi_images
                userInfo:userInfo];
      }
    });
}
-(void)onImageDownloaded:(NSNotification *)notif {

  if (notif == nil) {
    return;
  }

  MobiImage    *mobi_image = [notif object];
  NSDictionary *userInfo   = [notif userInfo];
  
  //TODO: se bajo con error ... ponemos un loguito?
  if(mobi_image == nil) {
    return;
  }
  
  NSString *url = [userInfo objectForKey:@"url"];
  //NSLog(@"onImageDownloaded: %@ -> %@", url, mobi_image.local_uri);
  
  //NSLog(@"BaseMobiView::currentUrl [%@]", self.currentUrl);
  if(self.currentUrl != url)
    return;
  BOOL do_update_main_webview = [ScreenManager isMainScreenPrefix:[mobi_image prefix]];
  UIWebView* _UIWebView = nil;
  if(do_update_main_webview)
    _UIWebView=self.primaryUIWebView;
  else
    _UIWebView=self.secondaryUIWebView;

  NSLog(@"onImageDownloaded - WebView:[%s] prefix:[%@]", _UIWebView==nil?"NIL":"NOT NIL", mobi_image.prefix);
  if(_UIWebView==nil)
    return;
  
  __block NSString *jsString  = [NSString stringWithFormat:@"update_image('%@')"
                                 , mobi_image.local_uri];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_UIWebView stringByEvaluatingJavaScriptFromString:jsString];
    jsString=nil;
  });
  
}

@end
