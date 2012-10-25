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
#import "SHK.h"
#import "ConfigHelper.h"
#import "iToast.h"

#import "HCYoutubeParser.h"

@implementation NoticiaViewController

@synthesize mainUIWebView, bottomUIView, optionsBottomMenuUIImageView, btnFontSizePlus, btnFontSizeMinus, loading_indicator, noticia_id, noticia_metadata, myYoutubeViewController, mYMobiPaperLib, headerUIImageView, offline_imgvw, offline_lbl;

-(BOOL)onlineOrShowError:(BOOL)showAlertIfNeeded{
  
  BOOL online = [self.mYMobiPaperLib areWeConnectedToInternet];
  
  if(!online&&showAlertIfNeeded)
  {
    [self showError:@"OFFLINE" message:@"Contenido del diario inalcanzable. Actualice la pantalla mas tarde."];
  }
  else{
    NSLog(@"onlineOrShowError NI err||offline");
  }
  
  self.offline_imgvw.hidden=online;
  self.offline_lbl.hidden=online;
  //if(!online) [self hideLoadingIndicator];
  
  return online;
}

-(BOOL)checkAndShowError{
  NSError*err=[mYMobiPaperLib getLasError];
  if(err==nil )
    return NO;
  [self showError:@"Aviso" message:@"Ha ocurrido un error. Actualice la pantalla mas tarde."];
  return YES;
  
}

-(void)showError:(NSString*)title message:(NSString*)message{
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
  [alert show];
  alert=nil;
  
}
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
  
  NSLog(@" fontsize: %@", jsString);
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

-(NSString *)cleanUrl:(NSString*)url{
  NSString *escapedURL =  [[[[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"] stringByReplacingOccurrencesOfString:@"//" withString:@"/"] stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
  return escapedURL;
}



- (void)playVideo:(NSURL *)_url{
  
  [self showLoadingIndicator];
  // Deshabilitamos el cache.
  
  __block NSString *video_id = [[self getYoutubeVideoId:[_url absoluteString]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
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
      // To get a thumbnail for an image there is now a async method for that
      /*[HCYoutubeParser thumbnailForYoutubeURL:url
                            thumbnailSize:YouTubeThumbnailDefaultHighQuality
                            completeBlock:^(UIImage *image, NSError *error) {
                              if (!error) {
                                self.thumbailImageView.image = image;
                              }
                              else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                [alert show];
                              }
                            }];
       */
      youtubeURL = nil;
      video_id=nil;
      
      [self hideLoadingIndicator];
    });
  });
  
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
  
  local_url=nil;
  regex=nil;
  _ids=nil;
  return ret;
}
 
- (void)playAudio:(NSURL *)_url
{
  [self showLoadingIndicator];
  /*__block*/ NSString * url = [[_url absoluteString] stringByReplacingOccurrencesOfString:@"audio://" withString:@"" ];
  url = [self cleanUrl:url];
  /*__block*/ MPMoviePlayerViewController* mpviewController = nil;
  
  //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    mpviewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
    mpviewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;//MPMovieSourceTypeStreaming;
    mpviewController.moviePlayer.controlStyle =MPMovieControlStyleFullscreen;
    
    [self presentModalViewController:mpviewController animated:YES];

    [[mpviewController moviePlayer] prepareToPlay];
    [[mpviewController moviePlayer] play];
    
  //dispatch_async(dispatch_get_main_queue(), ^{
      url=nil;
      mpviewController=nil;
      [self hideLoadingIndicator];
  //});
  //});
  return;
 
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
  
  if(![self onlineOrShowError:YES])
    return;
  
  // Create the item to share (in this example, a url)
	//NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
	NSURL *url = [NSURL URLWithString:self.noticia_metadata];
	SHKItem *item = [SHKItem URL:url title:@"ElDia.com.ar"];
  
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
  
	// Display the action sheet
	//[actionSheet showFromToolbar:app_delegate.navigationController.toolbar];
  [actionSheet showFromToolbar:self.navigationController.toolbar];
  
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.mYMobiPaperLib = [[YMobiPaperLib alloc] init];
      self.mYMobiPaperLib.delegate = self;
      networkGallery = nil;
    }
    return self;
}

-(void)loadBlank{
  [self.mainUIWebView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
  self.bottomUIView.hidden = YES;
}

-(void)setHtmlToView:(NSData*)data stop_loading_indicators:(BOOL)stop_loading_indicators{
  
  if(stop_loading_indicators)
  {
    [self hideLoadingIndicator];
  }
  
  if(data==nil){
    //[self onlineOrShowError:YES];
    return;
  }
  NSLog(@"MainViewController::setHtmlToView ME llamaron!!!");
  NSString *dirPath = [[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [self.mainUIWebView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:dirURL];
  
  data = nil;
  dirPath=nil;
  dirURL=nil;
  
}

-(void)loadNoticia:(NSString *)_noticia_id{
  
  [self showLoadingIndicator];
  // clean cont	ent
  
  [self setNoticia_id:_noticia_id];
  
  [self onlineOrShowError:YES];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSData* data = [self.mYMobiPaperLib getHtmlAndConfigure:YMobiNavigationTypeNews queryString:noticia_id xsl:XSL_PATH_NEWS tag:MSG_GET_NEW force_load:NO];
    // tell the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      if(data==nil)
      {
        [self checkAndShowError];
        [self hideLoadingIndicator];
        return;
      }

      [self setHtmlToView:data stop_loading_indicators:YES];
      [self changeFontSize:0];
      [self setNoticia_metadata:[self.mYMobiPaperLib metadata] ];
      data = nil;
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
  NSString *nextNoticiaId = [YMobiPaperLib getNextNoticiaId:noticia_id];
  if(nextNoticiaId!=nil)
  {
    [self loadNoticia:nextNoticiaId];
    nextNoticiaId=nil;
  }
}
-(void)handleRightSwipe :(UISwipeGestureRecognizer *)gesture{
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
  [self.headerUIImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
  networkCaptions = nil;
  networkImages = nil;
  networkGallery = nil;
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
  //[self changeFontSize:0];
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
    self.bottomUIView.hidden = YES; //HACK!
    
    if(![self onlineOrShowError:YES])
      return NO;
    
    bool handled = NO;
    if ([[url scheme]isEqualToString:SCHEMA_NOTICIA])
    {
      [self loadNoticia:[[url host] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]]];
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

// END


//YMobiPaperDelegate implementation
- (void) requestSuccessful:(id)data message:(NSString*)message{
  NSLog(@"NoticiaViewConteroller::requestSuccessful");
  
  //[self changeFontSize:0];
  //[self hideLoadingIndicator];
  //[self setNoticia_metadata:[self.mYMobiPaperLib metadata] ];
}

- (void) requestFailed:(id)error message:(NSString*)message{
  NSLog(@"NoticiaViewConteroller::requestFailed");
  //[self hideLoadingIndicator];
  //[[[iToast makeText:@"Ha ocurrido un error. Actualice la pantalla."] setGravity:iToastGravityTop offsetLeft:0 offsetTop:50] show];
  
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
