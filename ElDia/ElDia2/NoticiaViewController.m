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

#import "HCYoutubeParser.h"

@implementation NoticiaViewController

@synthesize mainUIWebView, bottomUIView, optionsBottomMenuUIImageView,
  btnFontSizePlus, btnFontSizeMinus, loading_indicator,
  myYoutubeViewController, headerUIImageView, offline_imgvw, offline_lbl,
  noticia_id, noticia_url, noticia_title, noticia_header, actionBar;

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
    else
    {
      
      NSLog(@"NoticiaViewController::changeFontSize delta=0 ");
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
        [self presentModalViewController:mp animated:NO];
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

  [self presentModalViewController:mpviewController animated:YES];

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

- (IBAction) btnShareClick: (id)param{
  
  if(![Utils areWeConnectedToInternet])
  {
    [self showMessage:@"No hay conexión de red.\nInténtelo más tarde." isError:YES];
    return;
  }

//  //http://socialize.github.com/socialize-sdk-ios/action_bar.html
//  if (self.actionBar != nil) {
//    [self.actionBar removeFromSuperview];
//    self.actionBar = nil;
//  }
//  if (self.actionBar == nil) {
//    NSLog(@"raw %@",self.noticia_url);
//    NSLog(@"decoded %@",[Utils stringByDecodingURLFormat:self.noticia_url ]);
//    NSString *text = [NSString stringWithFormat:@"%@ %@", [Utils stringByDecodingURLFormat:self.noticia_title], [Utils stringByDecodingURLFormat:self.noticia_url ]];
//    self.entity = [SZEntity entityWithKey:self.noticia_id name:text];
//    self.actionBar = [SZActionBar defaultActionBarWithFrame:CGRectNull entity:self.entity viewController:self];
//    
//    [self.view addSubview:self.actionBar];
//  }
  
  
//   NSURL *url = [NSURL URLWithString:self.noticia_url];
//   
//   SHKItem *item = [SHKItem URL:url title:[[NSString alloc] initWithFormat:@"%@ - ElDia.com.ar", self.noticia_title] ];
//  
//	// Get the ShareKit action sheet
//	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
//  
//	// Display the action sheet
//	[actionSheet showFromToolbar:self.navigationController.toolbar];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     networkGallery = nil;
    }
    return self;
}

-(void)loadBlank{
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
  self.bottomUIView.hidden = YES;
}

-(void)loadNoticia:(NSURL *)url{
  
  [self onLoading:YES];
  //noticia://guid?url=_url_&title=_title_&header=_header_
  [self setNoticia_id:[[url host] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]] ];
 
  URLParser *parser = [[URLParser alloc] initWithURLString:[url absoluteString]];
  
  [self setNoticia_url:[parser valueForVariable:@"url"]];
  [self setNoticia_title:[parser valueForVariable:@"title"]];
  [self setNoticia_header:[parser valueForVariable:@"header"]];
  parser=nil;
  
  NSString *uri = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host] ];
  
  if([self.mScreenManager articleExists:uri])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getArticle:uri useCache:YES error:&err];
    [self setHTML:data url:uri webView:self.mainUIWebView];
    return;
  }
  [self loadUrl:uri useCache:NO];
}

-(void)loadUrl:(NSString*)url useCache:(BOOL)useCache {
  
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
  [self.view addGestureRecognizer:rightSwipeRecognizer]; // add in your webviewrightSwipeRecognizer
  
  UISwipeGestureRecognizer* leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleLeftSwipe:)];
  leftSwipeRecognizer.numberOfTouchesRequired = 1;
  leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  leftSwipeRecognizer.cancelsTouchesInView = YES;
  leftSwipeRecognizer.delegate=self;
  [self.view addGestureRecognizer:leftSwipeRecognizer]; // add in your webviewrightSwipeRecognizer


}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([touch.view isKindOfClass:[UIView class]])
  {
    // only recognises gesture started on a button
    return YES;
  }
  return NO;
}

-(void)handleLeftSwipe :(UISwipeGestureRecognizer *)gesture{
  NSURL *nextNoticiaUrl = [NewsManager getNextNoticiaId:noticia_id];
  if(nextNoticiaUrl!=nil)
  {
    [self loadNoticia:nextNoticiaUrl];
    nextNoticiaUrl=nil;
  }
}
-(void)handleRightSwipe :(UISwipeGestureRecognizer *)gesture{
  NSURL *prevNoticiaUrl = [NewsManager getPrevNoticiaId:noticia_id];
  if(prevNoticiaUrl!=nil)
  {
    [self loadNoticia:prevNoticiaUrl];
    prevNoticiaUrl=nil;
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.mainUIWebView.delegate = self;
  self.mainUIWebView.hidden = NO;

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
  
  //hack
  if (self.actionBar != nil) {
//    [self.actionBar removeFromSuperview];
//    self.actionBar=nil;
    self.actionBar.hidden = YES;
  }
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
  [self onLoading:NO];
  [self changeFontSize:0];}

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
      [self loadNoticia:url];
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
   NSLog(@" Cantidad de imagenes en _images_src: %d", [_images_src count]);
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



-(void) onLoading:(BOOL)started{
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
  self.optionsBottomMenuUIImageView=nil;
  self.btnFontSizePlus=nil;
  self.btnFontSizeMinus=nil;
  self.loading_indicator=nil;
  
  self.headerUIImageView=nil;
  
  networkCaptions = nil;
  networkImages = nil;
  networkGallery = nil;

  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
