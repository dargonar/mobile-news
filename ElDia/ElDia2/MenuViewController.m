//
//  MenuViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController
@synthesize screenShotImageView, screenShotImage, tapGesture, panGesture, webView;

BOOL viewDidLoad = NO;
BOOL htmlSet = NO;
NSData*dati=nil;
NSLock *lock;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      viewDidLoad = NO;
      dati=nil;
      htmlSet= NO;
      lock=[[NSLock alloc] init];
    }
  
  return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //self.webView.scrollView.alwaysBounceHorizontal = NO;
  self.webView.hidden=NO;
  [self loadGesturesRecognizers];
  
  viewDidLoad=YES;
  [self loadDataIfExists];
}

-(void)loadDataIfExists{
  
  [lock lock];
  if(dati!=nil)
  {
    [self setHTML:dati url:nil webView:self.webView];
    htmlSet=YES;
    dati=nil;
    return;
  }
  [lock unlock];

  if(!htmlSet){
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"menu_dummy" ofType:@"html"];
    NSData*htmlData=  [NSData dataWithContentsOfFile:filePath];
    [self setHTML:htmlData url:nil webView:self.webView];
    [self loadUrl:YES];
  }
  
}

-(void)loadGesturesRecognizers{
  // create a UITapGestureRecognizer to detect when the screenshot recieves a single tap
  tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapScreenShot:)];
  [screenShotImageView addGestureRecognizer:tapGesture];
  
  // create a UIPanGestureRecognizer to detect when the screenshot is touched and dragged
  panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)];
  [panGesture setMaximumNumberOfTouches:2];
  [panGesture setDelegate:self];
  [screenShotImageView addGestureRecognizer:panGesture];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  // remove the gesture recognizers
  [self.screenShotImageView removeGestureRecognizer:self.tapGesture];
  [self.screenShotImageView removeGestureRecognizer:self.panGesture];
  
}

-(void)loadUrl:(BOOL)useCache{
  
  
  NSLog (@"MenuViewCotroller::loadUrl useCache[%@]", useCache?@"SI":@"NO");
  
  if(useCache && [self.mScreenManager menuExists])
  {
    NSError *err;
    NSData *data = [self.mScreenManager getMenu:YES error:&err];
    if(data!=nil)
    {
      
      if(viewDidLoad)
      {
        NSLog (@"MenuViewCotroller::loadUrl viewDidLoad");

        [self setHTML:data url:nil webView:self.webView];
        htmlSet=YES;
      }
      else
      {
        NSLog (@"MenuViewCotroller::loadUrl !viewDidLoad");

        [lock lock];
        dati=data;
        [lock unlock];
      }
      return;
    }
  }

  NSLog (@"MenuViewCotroller::loadUrl Dispatching");

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *err;
    __block NSData *data = [self.mScreenManager getMenu:NO error:&err];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if(data==nil)
      {
        return;
      }
      if(viewDidLoad)
      {
        [self setHTML:data url:nil  webView:self.webView];
        htmlSet=YES;
      }
      else
      {
        [lock lock];
        dati=data;
        [lock unlock];
      }
      data=nil; 
      
      
    });
  });

}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // when the menu view appears, it will create the illusion that the other view has slide to the side
  // what its actually doing is sliding the screenShotImage passed in off to the side
  // to start this, we always want the image to be the entire screen, so set it there
  [screenShotImageView setImage:self.screenShotImage];
  [screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  
  //[self adjustWebViewWidth:(320.0-44.0)];
  //[self adjustWebViewWidth:(320.0)];
  //[self adjustWebViewWidth:(480.0)];
  
  // now we'll animate it across to the right over 0.2 seconds with an Ease In and Out curve
  // this uses blocks to do the animation. Inside the block the frame of the UIImageView has its
  // x value changed to where it will end up with the animation is complete.
  // this animation doesn't require any action when completed so the block is left empty
  
  NSInteger _width = 276;
  if([app_delegate isiPad])
  {
    _width = 256;
  }
  
  [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [screenShotImageView setFrame:CGRectMake(_width, 0, self.view.frame.size.width, self.view.frame.size.height)];
  }
                   completion:^(BOOL finished){  }];
}

- (IBAction) btnCloseClick: (id)param{
  [self slideThenHide];
}

-(void) slideThenHide
{
  // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
  // it tells the app delegate using the completion block of the animation
  [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  }
                   completion:^(BOOL finished){ [app_delegate hideSideMenu]; }];
}

-(void) slideThenHideShowMenuClasificados
{
  // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
  // it tells the app delegate using the completion block of the animation
  [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  }
                   completion:^(BOOL finished){ [app_delegate hideSideMenuPushMenuClasificados]; }];
}

-(void) slideThenHideShowClasificados
{
  // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
  // it tells the app delegate using the completion block of the animation
  [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  }
                   completion:^(BOOL finished){ [app_delegate hideSideMenuPushClasificados]; }];
}

-(void) slideThenHideShowFarmacia
{
  // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
  // it tells the app delegate using the completion block of the animation
  [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  }
                   completion:^(BOOL finished){ [app_delegate hideSideMenuPushFarmacia]; }];
}

-(void) slideThenHideShowCartelera
{
  // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
  // it tells the app delegate using the completion block of the animation
  [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  }
                   completion:^(BOOL finished){ [app_delegate hideSideMenuPushCartelera]; }];
}


// HACK: Estaba comentado
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return NO;
}

- (BOOL) shouldAutorotate
{
  return NO; //[app_delegate isiPad];
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

//BOOL isShowingLandscapeView = NO;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  }

- (void)singleTapScreenShot:(UITapGestureRecognizer *)gestureRecognizer
{
  // on a single tap of the screenshot, assume the user is done viewing the menu
  // and call the slideThenHide function
  [self slideThenHide];
}


/* The following is from http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/ */

-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
  UIView *piece = [gesture view];
  [self adjustAnchorPointForGestureRecognizer:gesture];
  //NSLog(@"panGestureMoveAround");
  
  if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
    
    CGPoint translation = [gesture translationInView:[piece superview]];
    
    // I edited this line so that the image view cannont move vertically
    [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
    [gesture setTranslation:CGPointZero inView:[piece superview]];
    //    [self adjustWebViewWidth:(320-([piece center].x - translation.x))];
    //HACK [self adjustWebViewWidth:(320-([piece center].x + translation.x))];
  }
  else if ([gesture state] == UIGestureRecognizerStateEnded)
    [self slideThenHide];
}

-(void)adjustWebViewWidth:(CGFloat)_width{
  
  CGRect frame = webView.frame;
  if(frame.size.width==_width){
    return;
  }
  frame.size.width = _width;
  webView.frame = frame;

}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
  //NSLog(@"adjustAnchorPointForGestureRecognizer");
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    UIView *piece = gestureRecognizer.view;
    CGPoint locationInView = [gestureRecognizer locationInView:piece];
    CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
    
    piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
    
    piece.center = locationInSuperview;
  }
}


/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}*/

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  
  NSURL* url = [request URL];
  if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"section"])
  {
    [app_delegate loadSectionNews:url];
    [self slideThenHide];
    [BaseMobiViewController trackClick:[url absoluteString]];
    return NO;
  }
  else
    // iPad
    if (UIWebViewNavigationTypeLinkClicked == navigationType && ([[url scheme]isEqualToString:@"clasificados"] || [[url scheme]isEqualToString:@"funebres"] || [[url scheme]isEqualToString:@"farmacia"] || [[url scheme]isEqualToString:@"cartelera"]) && [app_delegate isiPad])
    {
      [app_delegate loadService:url];
      [self slideThenHide];
      [BaseMobiViewController trackClick:[url absoluteString]];
      return NO;
    }
    else
    // iPhone/iPod
    if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url scheme]isEqualToString:@"clasificados"] && [[url host]isEqualToString:@"list"]) // antes: page://clasificados
    {
      [app_delegate loadMenuClasificados:url];
      [self slideThenHideShowMenuClasificados];
      [BaseMobiViewController trackClick:[url absoluteString]];
      return NO;
    }
    else
      if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url absoluteString]isEqualToString:@"funebres://"]) // antes: page://funebres
      {
        [app_delegate loadFunebres:[[NSURL alloc]initWithString:@"funebres://" ]];
        [self slideThenHideShowClasificados];
        [BaseMobiViewController trackClick:[url absoluteString]];
        return NO;
      }
      else
      if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url absoluteString]isEqualToString:@"farmacia://"])
      {
        [app_delegate loadFarmacia:[[NSURL alloc]initWithString:@"farmacia://" ]];
        [self slideThenHideShowFarmacia];
        [BaseMobiViewController trackClick:[url absoluteString]];
        return NO;
      }
      else
        if (UIWebViewNavigationTypeLinkClicked == navigationType && [[url absoluteString]isEqualToString:@"cartelera://"])
        {
          [app_delegate loadCartelera:[[NSURL alloc]initWithString:@"cartelera://" ]];
          [self slideThenHideShowCartelera];
          [BaseMobiViewController trackClick:[url absoluteString]];
          return NO;
        }
        else
          if ([[url scheme]isEqualToString:@"http"])
          {
            [[UIApplication sharedApplication] openURL:url];
            [BaseMobiViewController trackClick:[url absoluteString]];
            return NO;
          }
  return YES;
  
}

@end
