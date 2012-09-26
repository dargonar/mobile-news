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


@implementation NoticiaViewController

@synthesize mainUIWebView, bottomUIView, optionsBottomMenuUIImageView, moviePlayer=_moviePlayer, myYoutubeViewController;

- (void)playVideo:(NSURL *)_url{
  
  NSString *youtube = @"http://m.youtube.com/#/watch?v=%@";
  
  NSURL *youtubeURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:youtube, [self getYoutubeVideoId:[_url absoluteString]]]];
  
  if (self.myYoutubeViewController == nil) {
    [self loadYoutubeViewController];
  }
  
  NSURLRequest *req = [NSURLRequest requestWithURL:youtubeURL];
  
  [app_delegate.navigationController pushViewController:myYoutubeViewController animated:YES];
  
  [self.myYoutubeViewController.mainUIWebView loadRequest:req];
}

-(void) loadYoutubeViewController{
  self.myYoutubeViewController= [[YoutubeViewController alloc]
                                 initWithNibName:@"YoutubeViewController" bundle:[NSBundle mainBundle]];
  self.myYoutubeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  
}


-(NSString *)getYoutubeVideoId:(NSString*)url{
  
  NSString * local_url = [url stringByReplacingOccurrencesOfString:@"video://" withString:@"" ];
  NSString *regex = @"^(?:https?://)?(?:www.)?(?:youtu.be/|youtube.com(?:/embed/|/v/|/watch\\?v=))([\\w-]{10,12})";
  NSArray *_ids = [local_url captureComponentsMatchedByRegex:regex];
  NSString *ret = @"";
  if ([_ids count]>2)
  {
    ret = [[NSString alloc] initWithFormat:@"%@",[_ids objectAtIndex:1]] ;
  }
  return ret;
}
 
- (void)playAudio:(NSURL *)_url
{
  NSURL *url = [NSURL URLWithString:@"http://www.eldia.com.ar/ediciones/20120906/20120906090522_1.mp3"];
  //NSURL *url = [NSURL URLWithString:@"http://www.youtube.com/watch?v=e3fsrQmHmfA"];
  //_moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
  MPMoviePlayerController *aPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
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
  
  if ([player
       respondsToSelector:@selector(setFullscreen:animated:)])
  {
    [player.view removeFromSuperview];
  }
}


- (IBAction) btnBackClick: (id)param{
  [[app_delegate navigationController] popViewControllerAnimated:YES];
}
- (IBAction) btnShareClick: (id)param{
  
  //[self playVideo:<#(NSURL *)#>];
  return;
  
  NSURL *myURL = [[NSURL alloc] initFileURLWithPath:@"http://www.eldia.com.ar/ediciones/20120906/20120906090522_1.mp3"];
  MPMoviePlayerController *player =  [[MPMoviePlayerController alloc] initWithContentURL:myURL];
  [player prepareToPlay];
  [player.view setFrame:self.view.bounds];  // player's frame must match parent's
  [self.view addSubview: player.view];
  [player play];
  
}

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
  self.bottomUIView.hidden = !self.bottomUIView.hidden;
  //NSLog(@"singleTapWebView");
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
  NSLog(@"webViewDidFinishLoad");
}

 -(void)webViewDidStartLoad:(UIWebView *)webView{
  NSLog(@"webViewDidStartLoad");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  NSLog(@"didFailLoadWithError: %@", error);
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
  
  NSLog(@" NSURL - 1: %@", [url absoluteString]);
  
  NSString *_gallery_proto = @"gallery://";
  NSString *_url=[url absoluteString];
  
  NSRange range = [_url rangeOfString:_gallery_proto];
  
  if ( range.length <= 0 ) {
    NSLog(@"loadPhotoGallery: [range.length <= 0] HAS NO PHOTO!");
    return;
  }
  
  _url=[_url stringByReplacingOccurrencesOfString:_gallery_proto withString:@""];
  NSArray *_images_src = [_url componentsSeparatedByString:@";"];
  
  if([_url length]<=0){
    NSLog(@"loadPhotoGallery: [[_url length]<=0] HAS NO PHOTO!");
    return;
  }
  
  if([_images_src count]<1){
    NSLog(@"loadPhotoGallery: [[_images_src count]<1] HAS NO PHOTO!");
    return;
  }
  
  /*
   http//media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f1.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f2.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f3.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f4.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f5.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f6.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f7.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f8.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f9.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f10.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f11.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f12.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f13.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f14.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f15.jpg
   */
  NSLog(@" Cantidad de imagenes en _images_src: %d", [_images_src count]);
  NSMutableArray *_array = [[NSMutableArray alloc] initWithCapacity:[_images_src count]];
  //for (int *i = 0; i < [_images_src count]; i++) {
  for (id object in _images_src) {
    //    NSString *escapedURL = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)([_images_src objectAtIndex:i]), NULL,                                                                                kCFStringEncodingUTF8);
    //NSString *escapedURL = [[NSString alloc] initWithCString:[_images_src objectAtIndex:i] encoding:NSUTF8StringEncoding];
    NSString *escapedURL =  [[[((NSString *)object) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"//" withString:@"/"] stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    
    NSLog(@"  escapedURL [%@]", escapedURL);
    
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

/*
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
  return [localImages objectAtIndex:index];
}
 */

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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
