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

NSString * const MAIN_SCREEN          = @"MAIN_SCREEN";
NSString * const NOTICIA_SCREEN       = @"NOTICIA_SCREEN";
NSString * const OTHER_SCREEN         = @"OTHER_SCREEN";


@interface BaseMobiViewController ()

@end

@implementation BaseMobiViewController

@synthesize mScreenManager, currentUrl, primaryUIWebView, secondaryUIWebView, adUIImageView;
@synthesize mAdManager;

BOOL mIsIpad=NO;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Custom initialization
      
      mIsIpad = [app_delegate isiPad];
      
      self.mScreenManager = [[ScreenManager alloc] init];
      mAdManager = [[AdManager alloc] init];
      //self.primaryUIWebView=nil;
      //self.secondaryUIWebView=nil;
      self.adUIImageView = nil;
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
  
  //return;
  //728x90  / 468x60 | 320x50 
  self.adUIImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320,50)];
  self.adUIImageView.hidden=YES;
  [self.view addSubview:self.adUIImageView];
  adUIImageView.userInteractionEnabled = YES;
  
}

-(BOOL)adStatus{
  if(self.adUIImageView==nil)
    return NO;
  return [self.adUIImageView isHidden];
}

-(NSInteger)adHeight{
  if(self.adUIImageView==nil)
    return 0;
  return  lrintf(self.adUIImageView.frame.size.height);
}

-(void)hideAd{
  if(self.adUIImageView==nil)
    return;
  dispatch_async(dispatch_get_main_queue(), ^{
    self.adUIImageView.hidden=YES;
  });
  return;
}

-(void)positionateAdMainScreen:(UIDeviceOrientation) deviceOrientation {
  [self positionateAd:deviceOrientation screen:MAIN_SCREEN];
}
-(void)positionateAdNoticiaScreen:(UIDeviceOrientation) deviceOrientation {
  [self positionateAd:deviceOrientation screen:NOTICIA_SCREEN];
}
-(void)positionateAdOtherScreen:(UIDeviceOrientation) deviceOrientation {
    [self positionateAd:deviceOrientation screen:OTHER_SCREEN];
}

NSString* click_url =@"";

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch *touch = [touches anyObject];
  
  if ([touch view] == adUIImageView && [click_url length]>0)
  {
    NSURL *url = [NSURL URLWithString:click_url];
    [[UIApplication sharedApplication] openURL:url];
  }
  
}

-(void)positionateAd:(UIDeviceOrientation) deviceOrientation screen:(NSString*)screen{
  
  // x y width height
  
  if(self.adUIImageView == nil)
    [self initAd];

  NSString* ad_size = @"320x50";
  
  NSInteger  height=self.view.frame.size.height;
  NSInteger  width=self.view.frame.size.width;
  
  __block NSDictionary*data=nil;
  
  // x y width height
  if (UIDeviceOrientationIsLandscape(deviceOrientation))
  {
    if ([app_delegate isiPad]) {
      if ([screen isEqualToString:MAIN_SCREEN]) {
        self.adUIImageView.frame=CGRectMake(256, height-90, width-256, 90);
        data = [mAdManager getLAdImage];
        ad_size = @"728x90";
      }
      else{

        self.adUIImageView.frame=CGRectMake(width/2, height-90, width/2, 90);
        data = [mAdManager getMAdImage];
        ad_size = @"468x60";
      }
    }
    else{
      self.adUIImageView.frame=CGRectMake(0, height-60, width, 60);
      data = [mAdManager getMAdImage];
      ad_size = @"468x60";
    }
  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation))
  {
    if ([app_delegate isiPad]) {
      if ([screen isEqualToString:MAIN_SCREEN]) {
        self.adUIImageView.frame=CGRectMake(0, height-90, width, 90);
        data = [mAdManager getLAdImage];
        ad_size = @"728x90";
      }
      else{
        self.adUIImageView.frame=CGRectMake(0, height-90, width, 90);
        data = [mAdManager getLAdImage];
        ad_size = @"728x90";
      }
    }
    else{
      self.adUIImageView.frame=CGRectMake(0, height-50, width, 50);
      data = [mAdManager getSAdImage];
      ad_size = @"320x50";
    }
  }
  
  if(data==nil)
  {
    click_url=@"";
    [self hideAd];
    return;
  }
  
  click_url = [mAdManager getClickUrl:data];
  
  dispatch_async(dispatch_get_global_queue(0,0), ^{
    __block NSData * image_data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[mAdManager getImageUrl:data]]];
    if ( image_data == nil )
    {
      [self hideAd];
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.adUIImageView setImage:[UIImage imageWithData: image_data]];
      self.adUIImageView.hidden=NO;
    });
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
  NSLog(@" downloaded image prefix [%@]", [mobi_image prefix]);
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
