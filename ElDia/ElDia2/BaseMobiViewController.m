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
#import "GAI.h"
#import "GAIFields.h"
#import "ConfigHelper.h"
#import "URLParser.h"

#import "MainViewController.h"
#import "ClasificadosViewController.h"

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
  [self colorizeGUIObjects];
  //[self initAdMob];
}


 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 //[self positionateAd];
  [self initAdMob];
 }



-(NSDictionary*)getBGColours{
  return [[NSDictionary alloc]initWithObjectsAndKeys:
          [UIColor colorWithRed:14.0/255.0 green:36.0/255.0 blue:64.0/255.0 alpha:1.0] , @"com.diventi.castellanos",
          [UIColor colorWithRed:12.0/255.0 green:118.0/255.0 blue:217.0/255.0 alpha:1.0] , @"com.diventi.ecosdiarios",
          [UIColor colorWithRed:47.0/255.0 green:112.0/255.0 blue:180.0/255.0 alpha:1.0] ,  @"com.diventi.eldia",
          [UIColor colorWithRed:205.0/255.0 green:33.0/255.0 blue:44.0/255.0 alpha:1.0] , @"com.diventi.pregon",
          [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:153.0/255.0 alpha:1.0] , @"com.diventi.lareforma",
          [UIColor colorWithRed:0.0/255.0 green:136.0/255.0 blue:205.0/255.0 alpha:1.0] , @"com.diventi.elnorte",
          [UIColor colorWithRed:174.0/255.0 green:10.0/255.0 blue:23.0/255.0 alpha:1.0] , @"com.diventi.puertonegocios"
          , nil];
  
}

-(NSDictionary*)getAppColours{
  return [[NSDictionary alloc]initWithObjectsAndKeys:
                                  [UIColor colorWithRed:255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] , @"com.diventi.castellanos",
                                  [UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0] , @"com.diventi.ecosdiarios",
                                  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] ,  @"com.diventi.eldia",
                                  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] , @"com.diventi.pregon",
                                  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] ,   @"com.diventi.lareforma",
                                  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] ,   @"com.diventi.elnorte",
                                  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] ,   @"com.diventi.puertonegocios",
                                  nil];

}



-(void)setColor:(UIView*)obj{
  NSDictionary *colors = [self getBGColours];
  UIColor* colorio = ((UIColor*)[colors objectForKey:[AppDelegate getBundleId]]);
  
  NSDictionary *colors2 = [self getAppColours];
  UIColor* colorio2 = ((UIColor*)[colors2 objectForKey:[AppDelegate getBundleId]]);
  if([[obj classForCoder] isSubclassOfClass:[UIActivityIndicatorView class]])
    //[((UIActivityIndicatorView*)obj) setColor:colorio];
    [((UIActivityIndicatorView*)obj) setColor:colorio2];
  
  if([[obj classForCoder] isSubclassOfClass:[UILabel class]])
    [((UILabel*)obj) setTextColor:colorio];
  
}

-(void)setBackgroundColor:(UIView*)view{
  NSDictionary *colors = [self getBGColours];
  UIColor* colorio = ((UIColor*)[colors objectForKey:[AppDelegate getBundleId]]);
//  NSLog(@"BaseMobiViewController::setBackgroundColor color:[%@]", [BaseMobiViewController colorToWeb:colorio]);
  [view setBackgroundColor:colorio];
}

-(void)colorizeGUIObjects{

  NSDictionary *colors = [self getAppColours];
  NSDictionary *bgcolors = [self getBGColours];
   for(UIView *subView in [self.view subviews]){
    
    if([[subView classForCoder] isSubclassOfClass:[UIActivityIndicatorView class]]==NO)
      continue;

    NSLog(@"colorizing: [%@] [%@]", [AppDelegate getBundleId], (UIColor*)[colors objectForKey:[AppDelegate getBundleId]]);

     if(subView.tag!=6969)
      [((UIActivityIndicatorView*)subView) setColor:(UIColor*)[colors objectForKey:[AppDelegate getBundleId]]];
     else
       [((UIActivityIndicatorView*)subView) setColor:(UIColor*)[bgcolors objectForKey:[AppDelegate getBundleId]]];  }
  
  if([[self classForCoder] isSubclassOfClass:[NoticiaViewController class]])
  {

  }
  
  if([[self classForCoder] isSubclassOfClass:[MainViewController class]])
  {
    [self setBackgroundColor:[((MainViewController*)self) error_view]];
    [self setBackgroundColor:[((MainViewController*)self) welcome_view]];
    [self setColor:[((MainViewController*)self) error_label]];
  }
  
  if([[self classForCoder] isSubclassOfClass:[ClasificadosViewController class]])
  {}
  
}
-(void)initAdMob{
  if([ConfigHelper isAdmobConfigured]==NO)
    return;
  
  if(([[self classForCoder] isSubclassOfClass:[NoticiaViewController class]] || [[self classForCoder] isSubclassOfClass:[MainViewController class]] || [[self classForCoder] isSubclassOfClass:[ClasificadosViewController class]] )==NO)
    return;
  
  // Create a view of the standard size at the top of the screen.
  // Available AdSize constants are explained in GADAdSize.h.
  bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
  // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
  bannerView_.adUnitID = [ConfigHelper getAdMobId];

  // Let the runtime know which UIViewController to restore after taking
  // the user wherever the ad goes and add it to the view hierarchy.
  bannerView_.rootViewController = self;
  [bannerView_ setDelegate:self];
  [self.view addSubview:bannerView_];
  
  /*
   GADRequest *request = [GADRequest request];
  
  // Make the request for a test ad. Put in an identifier for
  // the simulator as well as any devices you want to receive test ads.
  request.testDevices = [NSArray arrayWithObjects:
                         @"YOUR_SIMULATOR_IDENTIFIER",
                         @"YOUR_DEVICE_IDENTIFIER",
                         nil];
  */
  
  // Initiate a generic request to load it with an ad.
  [bannerView_ loadRequest:[GADRequest request]];
  
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
//  [UIView beginAnimations:@"BannerSlide" context:nil];
//  bannerView.frame = CGRectMake(0.0,
//                                self.view.frame.size.height -
//                                bannerView.frame.size.height,
//                                bannerView.frame.size.width,
//                                bannerView.frame.size.height);
//  [UIView commitAnimations];
  [self positionate:YES];
}

- (void)viewDidUnload
{
  [super viewDidUnload];

  [[NSNotificationCenter defaultCenter] removeObserver:self
                                               name:@"com.diventi.mobipaper.image_downloaded" 
                                             object:nil];

}

// No se utiliza mas.
 -(BOOL)initAd{
  
  if([ConfigHelper isAdmobConfigured])
    return NO;
  //728x90  / 468x60 | 320x50 
  self.adUIImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320,50)];
  self.adUIImageView.hidden=YES;
  [self.view addSubview:self.adUIImageView];
  adUIImageView.userInteractionEnabled = YES;
  return YES;
}


-(BOOL)adStatus{
  if(self.adUIImageView==nil)
    return NO;
  return [self.adUIImageView isHidden];
}

-(NSInteger)adHeight{
  if(bannerView_==nil)
    return 0;
  return  lrintf(bannerView_.frame.size.height);
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
  
  //AdMob
  if([ConfigHelper isAdmobConfigured])
  {
    [self positionateAdView:deviceOrientation screen:screen view:bannerView_ ];
    return;
  }
  return;
  
  //Comscore
  if(self.adUIImageView == nil)
    if([self initAd]==NO)
      return;
  NSString *ad_size = [self positionateAdView:deviceOrientation screen:screen view:self.adUIImageView ];
  
  __block NSDictionary*data=nil;
  if([ad_size isEqualToString:@"728x90"])
    data = [mAdManager getLAdImage];
  if([ad_size isEqualToString:@"468x60"])
    data = [mAdManager getMAdImage];
      if([ad_size isEqualToString:@"320x50"])
     data = [mAdManager getSAdImage];
     
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

-(NSString*)positionateAdView:(UIDeviceOrientation) deviceOrientation screen:(NSString*)screen view:(UIView*)view{

  NSString* ad_size = @"320x50";
  
  NSInteger  height=self.view.frame.size.height;
  NSInteger  width=self.view.frame.size.width;
  
  // x y width height
  if (UIDeviceOrientationIsLandscape(deviceOrientation))
  {
    if ([app_delegate isiPad]) {
      if ([screen isEqualToString:MAIN_SCREEN]) {
        view.frame=CGRectMake(256, height-90, width-256, 90);
        //data = [mAdManager getLAdImage];
        ad_size = @"728x90";
      }
      else{

        view.frame=CGRectMake(width/2, height-90, width/2, 90);
        //data = [mAdManager getMAdImage];
        ad_size = @"468x60";
      }
    }
    else{
      view.frame=CGRectMake(0, height-60, width, 60);
      //data = [mAdManager getMAdImage];
      ad_size = @"468x60";
    }
  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation))
  {
    if ([app_delegate isiPad]) {
      if ([screen isEqualToString:MAIN_SCREEN]) {
        view.frame=CGRectMake(0, height-90, width, 90);
        //data = [mAdManager getLAdImage];
        ad_size = @"728x90";
      }
      else{
        view.frame=CGRectMake(0, height-90, width, 90);
        //data = [mAdManager getLAdImage];
        ad_size = @"728x90";
      }
    }
    else{
      view.frame=CGRectMake(0, height-50, width, 50);
      //data = [mAdManager getSAdImage];
      ad_size = @"320x50";
    }
  }
  
  return ad_size;
  
    
  
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
- (void) setCurrentUrl:(id)_url{
  self->currentUrl = _url;
//  [BaseMobiViewController trackClick:_url];
}

+ (void) trackClick:(NSString*)_url
{
  
  
  NSArray * tracking_codes = [ConfigHelper getGATrackingCodes];
  
  if (tracking_codes==nil)
    return;

  //al 1er tracking code le mandamos la url interna (section://main), al resto le extirpamos el param de qs url (q es la del diario)
  // SCREEN_NAME , HIT_TYPE,  APP_ID.
  NSString *screen_name = [[_url componentsSeparatedByString:@"?"] objectAtIndex:0];
  NSString *hit_type =  [[[_url componentsSeparatedByString:@"://"] objectAtIndex:0] stringByAppendingString:@"://"];
  NSString *app_id = [AppDelegate getBundleId];
  URLParser *parser = [[URLParser alloc] initWithURLString:_url];
  NSString *url = [parser valueForVariable:@"url"];//[_url valueForKey:@"url"];
  parser=nil;
  if(url==nil || [url isEqualToString:@""])
    url = screen_name;

  NSLog(@"----------------------------");
  NSLog(@"BaseMobiViewController:: _url:[%@] screen_name:[%@] hit_type:[%@] app_id:[%@] url:[%@] ",
          _url, screen_name, hit_type, app_id, url);
        
  id<GAITracker> tracker1 = [[GAI sharedInstance]
                             trackerWithTrackingId:(NSString*)[tracking_codes objectAtIndex:0]
                             ];
 [tracker1 set:kGAIScreenName value:screen_name];
  /*NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                          hit_type, kGAIHitType,
                          screen_name, kGAIScreenName,
                          app_id, kGAIAppId,
                          nil];*/
  //  [tracker1 send:params];
//  [tracker1 send:[[GAIDictionaryBuilder createAppView] build]];
  [tracker1 send:[[GAIDictionaryBuilder  createEventWithCategory:@"ui_action"     // Event category (required)
                                                        action:@"button_press"  // Event action (required)
                                                         label:url          // Event label
                                                         value:nil] build]];    // Event value

  //NSLog(@" tracking code [%@]", (NSString*)[tracking_codes objectAtIndex:0]);
  // Send a screen view to the first property.

  if([tracking_codes count]==1)
    return;
  
  // Send another screen view to the second property.
  id<GAITracker> tracker2 = [[GAI sharedInstance]
                             trackerWithTrackingId:(NSString*)[tracking_codes objectAtIndex:1]];
  [tracker2 set:kGAIScreenName value:url];
  /*NSDictionary *params2 = [NSDictionary dictionaryWithObjectsAndKeys:
                          hit_type, kGAIHitType,
                          url, kGAIScreenName,
                          app_id, kGAIAppId,
                          nil];*/
  //[tracker2 send:params2];
  [tracker2 send:[[GAIDictionaryBuilder  createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:screen_name          // Event label
                                                           value:nil] build]];    // Event value

  

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
  
  __block NSString *jsString  = [NSString stringWithFormat:@"update_all_images();"];

//  NSLog(@"*************************************");
//  NSLog(@"onImageDownloaded: %@ -> %@", url, mobi_image.local_uri);
//  NSLog(@"BaseMobi::onImageDownloaded() [%@]", jsString);
//  NSLog(@"*************************************");
  
  dispatch_async(dispatch_get_main_queue(), ^{
    //[_UIWebView stringByEvaluatingJavaScriptFromString:jsString];
    if(self.primaryUIWebView!=nil)
      [self.primaryUIWebView stringByEvaluatingJavaScriptFromString:jsString];
    if(self.secondaryUIWebView!=nil)
      [self.secondaryUIWebView stringByEvaluatingJavaScriptFromString:jsString];
    jsString=nil;
  });
  
}

-(void)zoomToFitBig{

  if([[self classForCoder] isSubclassOfClass:[NoticiaViewController class]])
  {
    
    /*
     if ([[self secondaryUIWebView] isLoading]){
      NSLog(@"BaseMobi::zoomToFitBig  [self secondaryUIWebView] isLoading] >> NOTHING DONE");
      return;
    }
     */
    
    if ([self secondaryUIWebView]!=nil && [[self secondaryUIWebView] isLoading]==NO){
      if ([[self secondaryUIWebView] respondsToSelector:@selector(scrollView)])
      {
        float zoom=[self secondaryUIWebView].bounds.size.width/600.0;
        if([app_delegate isLandscape]==NO)
        {
          zoom=1.0;
        }
        NSLog(@"BaseMobi::zoomToFitBig  [[self secondaryUIWebView] ZOOMEANDO]");
        NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %f;",zoom];
        [[self secondaryUIWebView] stringByEvaluatingJavaScriptFromString:jsCommand];
    }
    else
      NSLog(@"BaseMobi::zoomToFitBig  [[self secondaryUIWebView] respondsToSelector:@selector(scrollView)]");
    }
    
    if ([self primaryUIWebView]!=nil && [[self primaryUIWebView] isLoading]==NO)
    {
      NSString *jsCommand = @"addClass(document.body, 'body660');";
      if([app_delegate isLandscape]==NO)
        jsCommand = @"removeClass(document.body, 'body660');";
      
      [[self primaryUIWebView] stringByEvaluatingJavaScriptFromString:jsCommand];
      
      //float zoom=[self primaryUIWebView].bounds.size.width/600.0;
      float zoom=1020.0/600.0;
      if([app_delegate isLandscape]==NO)
        zoom=1.0;
      jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %f;",zoom];
      [[self primaryUIWebView] stringByEvaluatingJavaScriptFromString:jsCommand];
    }
    return;
  }
  
  
}

-(void)zoomToFitSmall{
  if ([[self primaryUIWebView] respondsToSelector:@selector(scrollView)])
  {
    float zoom=[self primaryUIWebView].bounds.size.width/320.0;
    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %f;",zoom];
    [[self primaryUIWebView] stringByEvaluatingJavaScriptFromString:jsCommand];
  }
}

-(void)zoomToFit
{
 
//  NSLog(@"Is a kind of MainViewController: %@", ([[self classForCoder] isSubclassOfClass:[MainViewController class]])? @"Yes" : @"No");
  
  if([app_delegate isiPad])
  {
    [self zoomToFitBig];
    return;
  }

  [self zoomToFitSmall];
  
}


//-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
//  float x_offset=(scrollView.contentSize.width - self.view.frame.size.width)/2;
//  if (scrollView.contentOffset.x!=x_offset) {
//    scrollView.contentOffset = CGPointMake(x_offset, scrollView.contentOffset.y);
//  }
//}

@end
