//
//  NoticiaViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "NoticiaViewController.h"
#import "AppDelegate.h"
#import "ConfigHelper.h"
#import "iToast.h"
#import "Utils.h"
#import "URLParser.h"
#import "NewsManager.h"
#import "ErrorBuilder.h"
#import "SHK.h"
#import "HCYoutubeParser.h"

#import "GTMNSString+HTML.h"
 

@implementation NoticiaViewController

@synthesize mainUIWebView, menu_webview, bottomUIView, optionsBottomMenu;
@synthesize btnFontSizePlus, btnFontSizeMinus, loading_indicator;
@synthesize myYoutubeViewController, headerUIImageView, offline_view;
@synthesize noticia_id, noticia_url, noticia_title, noticia_header;
@synthesize pageControl, pageIndicator, shareBtn;


-(void)changeFontSize:(NSInteger)delta{
  
  CGFloat textFontSize = 1.0;
  NSString *_textFontSize = [ConfigHelper getSettingValue:CFG_NOTICIA_FONTSIZE];
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
  
  NSMutableString *partial_jsString = [[NSMutableString alloc] initWithFormat:@"document.getElementById('informacion').style.fontSize= '%fem';", textFontSize];
  
  NSString *jsString  = [partial_jsString  stringByAppendingFormat:@"document.getElementById('bajada').style.fontSize= '%fem'", textFontSize+0.2];
  
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  
  jsString=nil;
  partial_jsString=nil;
  if(fontChanged==YES)
  {
    [ConfigHelper setSettingValue:CFG_NOTICIA_FONTSIZE value:[[NSString alloc] initWithFormat:@"%f", textFontSize]];
  }

}
- (IBAction) btnFontSizePlusClick: (id)param{
  [self changeFontSize:1];
}
- (IBAction) btnFontSizeMinusClick: (id)param{
  [self changeFontSize:-1];

}

- (void)playVideo:(NSURL *)_url{
  
  
  [self onLoading:YES];
  // Deshabilitamos el cache.
  
  __block NSString *video_id = [[Utils getYoutubeId:[_url absoluteString]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
  __block NSURL *youtubeURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.youtube.com/watch?v=%@", video_id]];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //background task
  
    // Gets an dictionary with each available youtube url
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:youtubeURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      // update UI
    
      if(videos==nil || [[videos allKeys] count]<1)
      {
        if(self.myYoutubeViewController!=nil)
          self.myYoutubeViewController =nil;
        NSString *videoNibName = @"YoutubeViewController";
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
          videoNibName = @"YoutubeViewController_iPad";
        }
        self.myYoutubeViewController = [[YoutubeViewController alloc] initWithNibName:videoNibName bundle:[NSBundle mainBundle]];
        self.myYoutubeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.view addSubview:self.myYoutubeViewController.view];
  
        NSString *youtubeMobile = @"http://m.youtube.com/watch?v=%@"; //&autoplay=1";
        [self.myYoutubeViewController loadVideo:video_id req:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:youtubeMobile, video_id]]]];
        
        videoNibName=nil;
        youtubeMobile = nil;
      }
      else
      {
        // Presents a MoviePlayerController with the youtube quality medium
        MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videos objectForKey:@"medium"]] ];
        [mp.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [mp.moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
        [mp setWantsFullScreenLayout:YES];
        //[self presentModalViewController:mp animated:NO];
        [self presentViewController:mp animated:NO completion:nil];
        
        [mp.moviePlayer prepareToPlay];
        [mp.moviePlayer play];
        mp=nil;
      }
      
      youtubeURL = nil;
      video_id=nil;
      
      [self onLoading:NO];
    });
  });
  
}

- (void)playAudio:(NSURL *)url
{
  [self onLoading:YES];
  
  NSString * cleaned_url = [Utils cleanUrl:[[url absoluteString] stringByReplacingOccurrencesOfString:@"audio://" withString:@"" ]] ;
  MPMoviePlayerViewController* mpviewController = nil;
  
  mpviewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:cleaned_url]];
  mpviewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;//MPMovieSourceTypeStreaming;
  mpviewController.moviePlayer.controlStyle =MPMovieControlStyleFullscreen;

  //[self presentModalViewController:mpviewController animated:YES];
  [self presentViewController:mpviewController animated:YES completion:nil];
  
  [[mpviewController moviePlayer] prepareToPlay];
  [[mpviewController moviePlayer] play];

  cleaned_url=nil;
  mpviewController=nil;
  
  [self onLoading:NO];

}


- (void)moviePlaybackComplete:(NSNotification *)notification
{
  MPMoviePlayerController *moviePlayerController = [notification object];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
                                                object:moviePlayerController];
  
  [moviePlayerController.view removeFromSuperview];
  moviePlayerController = nil;
}

- (IBAction) btnBackClick: (id)param{
  [[app_delegate navigationController] popViewControllerAnimated:YES];
}

UIActionSheet* actionSheet;
- (IBAction) btnShareClick: (id)param{
  
  if(![Utils areWeConnectedToInternet])
  {
    [self showMessage:@"No hay conexión de red.\nInténtelo más tarde." isError:YES];
    return;
  }
  
  if (actionSheet) {
    [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    actionSheet = nil;
    return;
  }
  
  //NSURL *url = [NSURL URLWithString:[Utils stringByDecodingURLFormat:self.noticia_url]];
  NSURL *url = [NSURL URLWithString:self.noticia_url];
  
  SHKItem *item = [SHKItem URL:url
                        title:[[NSString alloc] initWithFormat:@"%@ - ElDia.com.ar", self.noticia_title]
                        contentType:SHKURLContentTypeWebpage];

	// Get the ShareKit action sheet
	//SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
  actionSheet = [SHKActionSheet actionSheetForItem:item];

	// Display the action sheet
	if([app_delegate isiPad])
    [actionSheet showFromRect:shareBtn.frame inView:self.view animated:YES];
  else
    [actionSheet showFromToolbar:self.navigationController.toolbar];
  
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      networkGallery = nil;
      self->currentSection=nil;
    }
    return self;
}

-(void)loadBlank{
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
  self.bottomUIView.hidden = YES;
}

-(void)invalidatePageIndicators{
  pageIndicator.hidden=YES;
  pageControl.hidden=YES;
}

-(void)initPageIndicators:(NSInteger)count index:(NSInteger)index{
  if(count>20)
  {
    pageIndicator.hidden=NO;
    pageControl.hidden=YES;
  }
  else
  {
    pageIndicator.hidden=YES;
    pageControl.hidden=NO;
  }
  
  pageControl.numberOfPages = count;
  pageIndicator.tag = count;
  
  [self setPageIndicatorIndex:index];
}

-(void)setPageIndicatorIndex:(NSInteger)index{
  pageControl.currentPage = index;
  [pageIndicator setText:[[NSString alloc] initWithFormat:@"%i / %i", (index+1),   pageIndicator.tag]];

}

-(void)loadNoticia:(NSURL *)url section:(NSString*)section {
  
  [self onLoading:YES];

  [self setNoticia_id:[[url host] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]] ];
 
  NSString* urlString = [Utils stringByDecodingURLFormat:[url absoluteString]] ;
  
  URLParser *parser = [[URLParser alloc] initWithURLString:[urlString gtm_stringByUnescapingFromHTML]];
  [self setNoticia_url:[parser valueForVariable:@"url"]];
  [self setNoticia_title:[parser valueForVariable:@"title"]];
  [self setNoticia_header:[parser valueForVariable:@"header"]];
  parser=nil;
  
  NSString *uri = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host] ];
  
  // Para ver si podemos recibir imagen updated.
  [self setCurrentUrl:uri];
  
  [self loadNoticia];
  if([app_delegate isiPad]==NO || (self->currentSection!=nil && [self->currentSection isEqualToString:section])) {
    [self setPageIndicatorIndex:[[NewsManager defaultNewsManager] getIndex:noticia_id]];
    return;
  }
  self->currentSection = section;
  [self loadSectionNews];
}

-(void)reLoadNoticia{
  [self loadNoticia];
}

-(void)loadNoticia{
  NSString*uri=[self currentUrl];
  if([self.mScreenManager articleExists:uri])
  {
    NSError *err;
    NSData*lastData = [self.mScreenManager getArticle:uri useCache:YES error:&err];
    [self setHTML:lastData url:uri webView:self.mainUIWebView];
  }
  else
  {
    [self loadUrl:uri useCache:YES];
  }
}

-(void)loadSectionNews{
  //HACK!
  //return;
  if ([app_delegate isiPad]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      __block NSError *err;
      __block NSData *data = [self.mScreenManager getSectionMenu:self->currentSection useCache:YES error:&err];
      dispatch_async(dispatch_get_main_queue(), ^{
        if(data==nil)
        {
          // data = dummy;
        }
        else
        {
          [self setHTML:data url:nil webView:self.menu_webview];
          [self initPageIndicators:[[NewsManager defaultNewsManager] getCount ] index:[[NewsManager defaultNewsManager] getIndex:noticia_id]];
          
        }
        data=nil;
      });
    });
  }
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache{
  
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getArticle:url useCache:useCache error:&err];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      if(data==nil)
      {
        [self onLoading:NO];
        
        if([err code]==ERR_NO_INTERNET_CONNECTION)
        {
          [self showMessage:@"No hay conexión de red.\nNo podemos acceder a la noticia." isError:YES];
        }
        return;
      }
      
      [self setHTML:data url:url webView:self.mainUIWebView];
      data=nil;
      
      
    });
  });
}

- (void)addGestureRecognizers{
  UISwipeGestureRecognizer* rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleRightSwipe:)];
  rightSwipeRecognizer.numberOfTouchesRequired = 1;
  rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  rightSwipeRecognizer.cancelsTouchesInView = YES;
  rightSwipeRecognizer.delegate=self;
  [self.mainUIWebView addGestureRecognizer:rightSwipeRecognizer]; // add in your webviewrightSwipeRecognizer
  
  UISwipeGestureRecognizer* leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleLeftSwipe:)];
  leftSwipeRecognizer.numberOfTouchesRequired = 1;
  leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  leftSwipeRecognizer.cancelsTouchesInView = YES;
  leftSwipeRecognizer.delegate=self;
  [self.mainUIWebView addGestureRecognizer:leftSwipeRecognizer]; // add in your webviewrightSwipeRecognizer

}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  
  if ([touch.view isKindOfClass:[UIView class]])
  {
    return YES;
  }
  return NO;
}

-(void)handleLeftSwipe :(UISwipeGestureRecognizer *)gesture{
  if(is_loading == YES)
    return;
  NSURL *nextNoticiaUrl = [[NewsManager defaultNewsManager] getNextNoticiaId:noticia_id];
  if(nextNoticiaUrl!=nil)
  {
    [self loadNoticia:nextNoticiaUrl section:self->currentSection ];
    nextNoticiaUrl=nil;
  }
}
-(void)handleRightSwipe :(UISwipeGestureRecognizer *)gesture{
  if(is_loading == YES)
    return;
  NSURL *prevNoticiaUrl = [[NewsManager defaultNewsManager] getPrevNoticiaId:noticia_id];
  if(prevNoticiaUrl!=nil)
  {
    [self loadNoticia:prevNoticiaUrl section:self->currentSection];
    prevNoticiaUrl=nil;
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  mWindow = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
  mWindow.viewToObserve = mainUIWebView;
  mWindow.controllerThatObserves = self;

  self.mainUIWebView.delegate = self;
  self.mainUIWebView.hidden = NO;
  self.mainUIWebView.tag=MAIN_VIEW_TAG;
  
  [[self mainUIWebView] setScalesPageToFit:YES];

  if ([app_delegate isiPad]) {
    self.menu_webview.delegate = self;
    self.menu_webview.hidden = NO;
    if([app_delegate isLandscape])
    {
      [self positionateLandscape];
    }
  }
  // Do any additional setup after loading the view from its nib.
  [self addGestureRecognizers];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
  app_delegate.navigationController.navigationBar.hidden=YES;
  [self.headerUIImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
  networkCaptions = nil;
  networkImages = nil;
  networkGallery = nil;
  
  if ([app_delegate isiPad]) {
    if([app_delegate isLandscape])
    {
      [self positionateLandscape];
    }
  }
  
}
  
- (void)webView:(UIWebView*)sender zoomingEndedWithTouches:(NSSet*)touches event:(UIEvent*)event
{
	//NSLog(@"finished zooming");
}

- (void)userDidTapWebView:(id)tapPoint{
  [self singleTapWebView];
}

/*
 - (void)webView:(UIWebView*)sender tappedWithTouch:(UITouch*)touch event:(UIEvent*)event
{
	NSLog(@"tapped");
  [self singleTapWebView];
}
*/
- (void)singleTapWebView {
  
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
  [self onLoading:NO];
  
  
  if (webView.tag!=MAIN_VIEW_TAG) {
    return;
  }
  
  //[[self mainUIWebView] setScalesPageToFit:YES];
  [self changeFontSize:0];
  
   if (!app_delegate.isiPad){
     return;
   }
  
  
  [self.mainUIWebView reload];
  NSString *jsString =     jsString = @"document.body.style.width = '1020px !important';var metayi = document.querySelector('meta[name=viewport]'); metayi.setAttribute('content','width:1020; user-scalable=YES;');metayi.setAttribute('content','width:1020; user-scalable=NO;');";

  if(isLandscapeView==YES)
    jsString = @"document.body.style.width = '660px';var metayi = document.querySelector('meta[name=viewport]'); metayi.setAttribute('content','width:660; user-scalable=YES;');metayi.setAttribute('content','width:660; user-scalable=NO;');";
  
  NSString* result =[self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  NSLog(@" -|- EvaluateJS:[%@] result:[%@]",jsString, result);
  
  //[self.mainUIWebView ]
}


 -(void)webViewDidStartLoad:(UIWebView *)webView{
   //NSLog(@"webViewDidStartLoad");
   //[self showLoadingIndicator];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  [self onLoading:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  NSURL* url = [request URL];
  
  //validar URL
  if (UIWebViewNavigationTypeLinkClicked == navigationType)
  {
    self.bottomUIView.hidden = YES; //HACK!
    
    if(![Utils areWeConnectedToInternet])
    {
      [self showMessage:@"No hay conexión de red.\nNo podemos desplegar el contenido solicitado." isError:YES];
      return NO;
    }
    
    bool handled = NO;
    if ([[url scheme]isEqualToString:@"noticia"])
    {
      [self loadNoticia:url section:self->currentSection];
      handled = YES;
    }
    else if ([[url scheme]isEqualToString:@"video"])
    {
      [self playVideo:url];
      handled = YES;
    }
    else if ([[url scheme]isEqualToString:@"audio"])
    {
      [self playAudio:url];
      handled = YES;
    }
    else if ([[url scheme]isEqualToString:@"galeria"])
    {
      [self loadPhotoGallery:url];
      handled = YES;
    }
    url=nil;
    if(handled == YES)
    {
      return NO;
    }
    return NO; //YES;
  }
  url=nil;
  return YES;
}

-(void) loadPhotoGallery:(NSURL *)url{
  
  if(networkGallery!=nil)
  {
    if([networkGallery.tagID isEqualToString:self.noticia_id]==NO)
      networkGallery=nil;
  }
  //NSLog(@" NSURL - 1: %@", [url absoluteString]);
  
  NSString *_gallery_proto = @"galeria://";
  NSString *_url=[url absoluteString];
  
  if([_url length]<=0){
    //NSLog(@"loadPhotoGallery: [[_url length]<=0] HAS NO PHOTO!");
    return;
  }
  
  NSRange range = [_url rangeOfString:_gallery_proto];
  
  if ( range.length <= 0 ) {
    //NSLog(@"loadPhotoGallery: [range.length <= 0] HAS NO PHOTO!");
    return;
  }
  
  _url=[_url stringByReplacingOccurrencesOfString:_gallery_proto withString:@""];
  NSArray *_images_src = [_url componentsSeparatedByString:@";"];
  
  if([_images_src count]<1){
    //NSLog(@"loadPhotoGallery: [[_images_src count]<1] HAS NO PHOTO!");
    return;
  }
  //NSLog(@" Cantidad de imagenes en _images_src: %d", [_images_src count]);
  NSMutableArray *_array = [[NSMutableArray alloc] initWithCapacity:[_images_src count]];
  //for (int *i = 0; i < [_images_src count]; i++) {
  for (id object in _images_src) {
    NSString *escapedURL = [Utils cleanUrl:((NSString *)object)];
    NSURL *candidateURL = [NSURL URLWithString:escapedURL];
    // WARNING > "test" is an URL according to RFCs, being just a path
    // so you still should check scheme and all other NSURL attributes you need
    if (candidateURL && candidateURL.scheme && candidateURL.host) {
      // candidate is a well-formed url with:
      //  - a scheme (like http://)
      //  - a host (like stackoverflow.com)
      [_array addObject:escapedURL];
    }
    candidateURL=nil;
    escapedURL=nil;
  }
  
  networkCaptions = [[NSArray alloc]initWithArray:_array copyItems:YES];
  networkImages = [[NSArray alloc]initWithArray:_array copyItems:YES];
  
  networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
  networkGallery.tagID = self.noticia_id;
  
  [app_delegate.navigationController  pushViewController:networkGallery animated:YES];
  app_delegate.navigationController.navigationBar.hidden=NO;
  
  
  _gallery_proto = nil;
  _url=nil;
  _array =nil;
  _images_src = nil;
  
  //networkCaptions = nil;
  //networkImages = nil;
  //networkGallery = nil;
  //NSLog(@"GalleryPhotos cargada!");
}

#pragma mark - FGalleryViewControllerDelegate Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
  int num;
  num = [networkImages count];
  return num;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
  return FGalleryPhotoSourceTypeNetwork;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
  return @"";
  //NSString *caption;
  //caption = [networkCaptions objectAtIndex:index];
  //return caption;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
  if(index>= [networkImages count])
    return [networkImages objectAtIndex:0];
  
  //if(index< 0)
  //  return [networkImages objectAtIndex:([networkImages count]-1)];
  
  return [networkImages objectAtIndex:index];
}

- (void)handleTrashButtonTouch:(id)sender {
  // here we could remove images from our local array storage and tell the gallery to remove that image
  // ex:
  //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}

- (void)handleEditCaptionButtonTouch:(id)sender {
  // here we could implement some code to change the caption for a stored image
}


BOOL is_loading = YES;
-(void) onLoading:(BOOL)started{
  is_loading=started;
  self.loading_indicator.hidden = !started;
  if(started)
    [self.loading_indicator startAnimating];
  else
    [self.loading_indicator stopAnimating];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.bottomUIView=nil;
  self.mainUIWebView=nil;
  self.optionsBottomMenu=nil;
  self.btnFontSizePlus=nil;
  self.btnFontSizeMinus=nil;
  self.loading_indicator=nil;
  
  self.headerUIImageView=nil;
  
  networkCaptions = nil;
  networkImages = nil;
  networkGallery = nil;

  
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

BOOL isLandscapeView = NO;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  
  if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
      !isLandscapeView)
  {
    [self positionateLandscape];
  }
  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
           isLandscapeView)
  {
    [self positionatePortrait];
  }
  [self loadSectionNews];
}

-(void)positionateLandscape{

  isLandscapeView = YES;
  
  if([app_delegate isiPad])
  {
    NSInteger  width=self.view.frame.size.width;
    NSInteger  height=self.view.frame.size.height;
    // x y width height
  
    self.mainUIWebView.frame=CGRectMake(width/2, 44, width/2, height-44);
    //[self.mainUIWebView reload];
  
    self.menu_webview.frame=CGRectMake(0, 44, width/2, height-44);
    [[self menu_webview] setScalesPageToFit:YES];
  
    self.optionsBottomMenu.frame = CGRectMake(width/2, height-self.optionsBottomMenu.frame.size.height, width/2, optionsBottomMenu.frame.size.height);
  
    self.pageControl.frame = CGRectMake(width/2, height-self.pageControl.frame.size.height, width/2, pageControl.frame.size.height);
  
    self.pageIndicator.frame = CGRectMake((width/2+width/2/2-self.pageIndicator.frame.size.width/2), height-self.pageIndicator.frame.size.height-8, self.pageIndicator.frame.size.width, pageIndicator.frame.size.height);
  
    self.loading_indicator.frame = CGRectMake( (width/2+width/2/2-self.loading_indicator.frame.size.width/2), height/2, self.loading_indicator.frame.size.width, loading_indicator.frame.size.height);
  
    //[self loadSectionNews];
  }
  //[self reLoadNoticia];
   [mainUIWebView reload];
}

-(void)positionatePortrait{
  
  isLandscapeView = NO;
  if([app_delegate isiPad])
  {
    NSInteger  width=self.view.frame.size.width;
    NSInteger  height=self.view.frame.size.height;
    // x y width height
    self.mainUIWebView.frame=CGRectMake(0, 44+246, width, height-44-246);
    //[self.mainUIWebView reload];
  
    [[self menu_webview] setScalesPageToFit:NO];
    self.menu_webview.frame=CGRectMake(0, 44, width, 246);
  
    self.optionsBottomMenu.frame = CGRectMake(0, height-self.optionsBottomMenu.frame.size.height, width, optionsBottomMenu.frame.size.height);
  
    self.pageControl.frame = CGRectMake(0, height-self.pageControl.frame.size.height, width, pageControl.frame.size.height);
  
    self.pageIndicator.frame = CGRectMake((width/2-self.pageIndicator.frame.size.width/2), height-self.pageIndicator.frame.size.height-8, self.pageIndicator.frame.size.width, pageIndicator.frame.size.height);
  
    self.loading_indicator.frame = CGRectMake(width/2, height/2, self.loading_indicator.frame.size.width, loading_indicator.frame.size.height);
    //[self reLoadNoticia];
    //[self loadSectionNews];

  }
    [mainUIWebView reload];
}


@end
