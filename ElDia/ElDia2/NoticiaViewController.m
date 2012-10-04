//
//  NoticiaViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "NoticiaViewController.h"
#import "AppDelegate.h"
#import "RegexKitLite.h"
#import "LocalSubstitutionCache.h"
#import "SHK.h"
#import "ConfigHelper.h"
#import "iToast.h"

@implementation NoticiaViewController

@synthesize mainUIWebView, bottomUIView, optionsBottomMenuUIImageView, moviePlayer=_moviePlayer, myYoutubeViewController, btnFontSizePlus, btnFontSizeMinus, loading_indicator, noticia_id, noticia_metadata;

-(void)changeFontSize:(NSInteger)delta{
  NSInteger textFontSize = 14;
  NSString *_textFontSize = [ConfigHelper getSettingValue:CFG_NOTICIA_FONTSIZE];
  if(_textFontSize!=nil)
  {
    textFontSize = [_textFontSize intValue];
  }
  bool fontChanged = NO;
  if(delta<0) {
      textFontSize = (textFontSize > 10) ? textFontSize -2 : textFontSize;
    fontChanged=YES;
  }
  else
    if(delta>0) {
      textFontSize = (textFontSize < 26) ? textFontSize +2 : textFontSize;
      fontChanged=YES;
    }
    else
    {
      
      //NSLog(@" delta=0 -> FONTSize:[%d]", textFontSize);
      //textFontSize = defaultTextFontSize;
    }
    
  NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementById('informacion').style.fontSize= '%dpx';document.getElementById('informacion').style.lineHeight= '%dpx';", textFontSize, (textFontSize+2)];
  
  [mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
  
  jsString=nil;
  if(fontChanged==YES)
  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      [ConfigHelper setSettingValue:CFG_NOTICIA_FONTSIZE value:[[NSString alloc] initWithFormat:@"%d", textFontSize]];
    });
   }

}
- (IBAction) btnFontSizePlusClick: (id)param{
  [self changeFontSize:1];
}
- (IBAction) btnFontSizeMinusClick: (id)param{
  [self changeFontSize:-1];

}

-(NSString *)cleanUrl:(NSString*)url{
  NSString *escapedURL =  [[[[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"] stringByReplacingOccurrencesOfString:@"//" withString:@"/"] stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
  return escapedURL;
}

- (void)playVideo:(NSURL *)_url{
  
  [LocalSubstitutionCache cacheOrNot:NO];
  
  NSString *youtube = @"http://m.youtube.com/watch?v=%@&autoplay=1";
  //http://m.youtube.com/watch?v=PLyEQF13kx4&autoplay=1
  
  NSString *video_id = [[self getYoutubeVideoId:[_url absoluteString]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
  NSLog(@"NoticiaViewController::playVideo video_id=%@", video_id);
  NSURL *youtubeURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:youtube, video_id]];
  
  if (self.myYoutubeViewController == nil) {
    [self loadYoutubeViewController];
  }
  
  NSURLRequest *req = [NSURLRequest requestWithURL:youtubeURL];
  
  //[app_delegate.navigationController pushViewController:myYoutubeViewController animated:YES];
  [self.view addSubview:[self.myYoutubeViewController view]];
  [self.myYoutubeViewController.mainUIWebView loadRequest:req];
}

-(void) loadYoutubeViewController{
  self.myYoutubeViewController= [[YoutubeViewController alloc]
                                 initWithNibName:@"YoutubeViewController" bundle:[NSBundle mainBundle]];
  self.myYoutubeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  
}

/*
   '%^# Match any youtube URL
   
   (?:https?://)?  # Optional scheme. Either http or https
   (?:www\.)?      # Optional www subdomain
   (?:             # Group host alternatives
   youtu\.be/    # Either youtu.be,
   
   | youtube\.com  # or youtube.com
   (?:           # Group path alternatives
   /embed/     # Either /embed/
   | /v/         # or /v/
   | /watch\?v=  # or /watch\?v=
   
   )             # End path alternatives.
   )               # End host alternatives.
   ([\w-]{10,12})  # Allow 10-12 for 11 char youtube id.
   $%x'
   
   Tested on 
   http://www.youtube.com/watch?v=e3fsrQmHmfA
   http://youtu.be/SA2iWivDJiE
   http://www.youtube.com/watch?v=_oPAwA_Udwc&feature=feedu
   http://www.youtube.com/embed/SA2iWivDJiE
   http://www.youtube.com/v/SA2iWivDJiE?version=3&amp;hl=en_US   
 */
-(NSString *)getYoutubeVideoId:(NSString*)url{
  
  NSLog(@"NoticiaViewcontroller::getYoutubeVideoId url=%@", url);
  
  NSString * local_url = [url stringByReplacingOccurrencesOfString:@"video://" withString:@"" ];
  local_url = [self cleanUrl:local_url];
  
  NSString *regex = @"^(?:https?://)?(?:www.)?(?:youtu.be/|youtube.com(?:/embed/|/v/|/watch\\?v=))([\\w-]{10,12})";
  NSArray *_ids = [local_url captureComponentsMatchedByRegex:regex];
  NSString *ret = @"";
  
  NSLog(@"NoticiaViewcontroller::getYoutubeVideoId ComponentsMatched=%@", _ids);
  
  if ([_ids count]>1)
  {
    ret = [[NSString alloc] initWithFormat:@"%@",[_ids objectAtIndex:1]] ;
  }
  return ret;
}
 
- (void)playAudio:(NSURL *)_url
{
  NSString * url = [[_url absoluteString] stringByReplacingOccurrencesOfString:@"audio://" withString:@"" ];
  url = [self cleanUrl:url];
  
  //NSURL *url = [NSURL URLWithString:@"http://www.eldia.com.ar/ediciones/20120906/20120906090522_1.mp3"];
  //NSURL *myURL = [[NSURL alloc] initFileURLWithPath:@"http://www.eldia.com.ar/ediciones/20120906/20120906090522_1.mp3"];
  NSURL *audio_url = [[NSURL alloc] initFileURLWithPath:url];
  
  MPMoviePlayerController *aPlayer = [[MPMoviePlayerController alloc] initWithContentURL:audio_url];
  [self setMoviePlayer:aPlayer];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(moviePlayBackDidFinish:)
                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                        object:_moviePlayer];
  
  _moviePlayer.controlStyle = MPMovieControlStyleDefault;
  _moviePlayer.shouldAutoplay = YES;
  [_moviePlayer prepareToPlay];
  [self.view addSubview:_moviePlayer.view];
  [_moviePlayer setFullscreen:YES animated:YES];
  [_moviePlayer play];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
  
  MPMoviePlayerController *player = [notification object];
  [[NSNotificationCenter defaultCenter]
    removeObserver:self
    name:MPMoviePlayerPlaybackDidFinishNotification
    object:player];
  
  if([player respondsToSelector:@selector(setFullscreen:animated:)])
  {
    [player.view removeFromSuperview];  
  }
}


- (IBAction) btnBackClick: (id)param{
  [[app_delegate navigationController] popViewControllerAnimated:YES];
}
- (IBAction) btnShareClick: (id)param{
  
  // Create the item to share (in this example, a url)
	//NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
	NSURL *url = [NSURL URLWithString:self.noticia_metadata];
	SHKItem *item = [SHKItem URL:url title:@"ElDia.com.ar"];
  
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
  
	// Display the action sheet
	[actionSheet showFromToolbar:app_delegate.navigationController.toolbar];
  
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.mYMobiPaperLib = [[YMobiPaperLib alloc] init];
      self.mYMobiPaperLib.delegate = self;
    }
    return self;
}

-(void)loadNoticia:(NSString *)_noticia_id{
  [self showLoadingIndicator];
  // clean content
  [self.mainUIWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
  
  [self setNoticia_id:_noticia_id];
  [self.mYMobiPaperLib loadHtmlAsync:YMobiNavigationTypeNews queryString:noticia_id xsl:XSL_PATH_NEWS _webView:self.mainUIWebView tag:MSG_GET_NEW force_load:NO];
  
  
  
  //[self.mYMobiPaperLib loadHtml:YMobiNavigationTypeNews queryString:[url host] xsl:XSL_PATH_NEWS _webView:self.mainUIWebView];
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
  //[[[iToast makeText:@"next noticia please"] setGravity:iToastGravityTop offsetLeft:0 offsetTop:50] show];
  //stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]
  NSString *nextNoticiaId = [YMobiPaperLib getNextNoticiaId:noticia_id];
  if(nextNoticiaId!=nil)
  {
    [self loadNoticia:nextNoticiaId];
    nextNoticiaId=nil;
  }
}
-(void)handleRightSwipe :(UISwipeGestureRecognizer *)gesture{
  //[[[iToast makeText:@"noticia anterior nene"] setGravity:iToastGravityTop offsetLeft:0 offsetTop:50] show];
  NSString *prevNoticiaId = [YMobiPaperLib getPrevNoticiaId:noticia_id];
  if(prevNoticiaId!=nil)
  {
    [self loadNoticia:prevNoticiaId];
    prevNoticiaId=nil;
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
  [LocalSubstitutionCache cacheOrNot:YES];

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
  self.bottomUIView.hidden = !self.bottomUIView.hidden;
  //NSLog(@"singleTapWebView");
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
  [self changeFontSize:0];
  //[self hideLoadingIndicator];
  NSLog(@"webViewDidFinishLoad");
}

 -(void)webViewDidStartLoad:(UIWebView *)webView{
   //NSLog(@"webViewDidStartLoad");
   //[self showLoadingIndicator];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  //NSLog(@"didFailLoadWithError: %@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  NSURL* url = [request URL];
  
  //validar URL
  if (UIWebViewNavigationTypeLinkClicked == navigationType)
  {
    bool handled = NO;
    if ([[url scheme]isEqualToString:SCHEMA_NOTICIA])
    {
      // Aca tenemos que lodear otra noticia!!
      handled = YES;
    }
    else if ([[url scheme]isEqualToString:SCHEMA_VIDEO])
    {
      [self playVideo:url];
      handled = YES;
    }
    else if ([[url scheme]isEqualToString:SCHEMA_AUDIO])
    {
      [self playAudio:url];
      handled = YES;
    }
    else if ([[url scheme]isEqualToString:SCHEMA_GALERIA])
    {
      [self loadPhotoGallery:url];
      handled = YES;
    }
    
    if(handled == YES)
      return NO;
    return NO; //YES;
  }
  return YES;
}

-(void) loadPhotoGallery:(NSURL *)url{
  
  //NSLog(@" NSURL - 1: %@", [url absoluteString]);
  
  NSString *_gallery_proto = @"gallery://";
  NSString *_url=[url absoluteString];
  
  NSRange range = [_url rangeOfString:_gallery_proto];
  
  if ( range.length <= 0 ) {
    //NSLog(@"loadPhotoGallery: [range.length <= 0] HAS NO PHOTO!");
    return;
  }
  
  _url=[_url stringByReplacingOccurrencesOfString:_gallery_proto withString:@""];
  NSArray *_images_src = [_url componentsSeparatedByString:@";"];
  
  if([_url length]<=0){
    //NSLog(@"loadPhotoGallery: [[_url length]<=0] HAS NO PHOTO!");
    return;
  }
  
  if([_images_src count]<1){
    //NSLog(@"loadPhotoGallery: [[_images_src count]<1] HAS NO PHOTO!");
    return;
  }
   NSLog(@" Cantidad de imagenes en _images_src: %d", [_images_src count]);
  NSMutableArray *_array = [[NSMutableArray alloc] initWithCapacity:[_images_src count]];
  //for (int *i = 0; i < [_images_src count]; i++) {
  for (id object in _images_src) {
    NSString *escapedURL = [self cleanUrl:((NSString *)object)];
    
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
    
  }
  
  networkCaptions = [[NSArray alloc]initWithArray:_array copyItems:YES];
  networkImages = [[NSArray alloc]initWithArray:_array copyItems:YES];
  
  networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
  
  [app_delegate.navigationController  pushViewController:networkGallery animated:YES];
  //[networkGallery release];
  
  app_delegate.navigationController.navigationBar.hidden=NO;
  
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
  
  if(index< 0)
    return [networkImages objectAtIndex:([networkImages count]-1)];
  
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

// END


//YMobiPaperDelegate implementation
- (void) requestSuccessful:(id)data message:(NSString*)message{
  [self changeFontSize:0];
  [self hideLoadingIndicator];
  [self setNoticia_metadata:[self.mYMobiPaperLib metadata] ];
}

- (void) requestFailed:(id)error message:(NSString*)message{
  [self hideLoadingIndicator];
}

-(void) showLoadingIndicator{
  //btnRefreshClick.hidden=YES;
  //btnRefreshClick.enabled=NO;
  self.loading_indicator.hidden = NO;
  [self.loading_indicator startAnimating];
}
-(void) hideLoadingIndicator{
  //btnRefreshClick.hidden=NO;
  //btnRefreshClick.enabled=YES;
  self.loading_indicator.hidden = YES;
  [self.loading_indicator stopAnimating];
  
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.mYMobiPaperLib = nil;
  self.myYoutubeViewController=nil;
  self.moviePlayer=nil;
  self.bottomUIView=nil;
  self.mainUIWebView=nil;
  self.optionsBottomMenuUIImageView=nil;
  self.btnFontSizePlus=nil;
  self.btnFontSizeMinus=nil;
  self.loading_indicator=nil;
  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
