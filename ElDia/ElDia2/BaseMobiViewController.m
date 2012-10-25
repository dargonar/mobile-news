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

@synthesize mScreenManager, mainUIWebView, currentUrl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      self.mScreenManager = [[ScreenManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*****/

-(void)configureToast{
  iToastSettings *theSettings = [iToastSettings getSharedSettings];
  theSettings.duration = 2500;
  UIImage *warning_image = [UIImage imageNamed: @"warning.png"];
  [theSettings setImage:warning_image forType:iToastTypeWarning];
}

-(BOOL)isOld:(NSDate*)date {
  if(date==nil)
    return YES;
  NSTimeInterval t= [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:date];
  if(t > (60*60*2))
    return YES;
  
  return NO;
}

-(void)setHTML:(NSData*)data url:(NSString*)url{
  [mainUIWebView  loadData:data
                  MIMEType:@"text/html"
          textEncodingName:@"utf-8"
                   baseURL:[[DiskCache defaultCache] getFolderUrl]];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSError *err;
     NSArray *mobi_images = [self.mScreenManager getPendingImages:url error:&err];
     [app_delegate downloadImages:mobi_images obj:self request_url:url];
     
  });
}
-(void)onImageDownloaded:(MobiImage*)mobi_image url:(NSString*)url{
  
  if(self.currentUrl!=url)
    return;
  
  __block NSString *jsString  = [NSString stringWithFormat:@"document.getElementById('%@').style.backgroundImage = ''; document.getElementById('%@').style.backgroundImage = 'url(%@)';"
                                 , mobi_image.local_uri
                                 , mobi_image.local_uri
                                 , [NSString stringWithFormat:@"i_%@", mobi_image.local_uri ] ];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.mainUIWebView stringByEvaluatingJavaScriptFromString:jsString];
    jsString=nil;
  });
  
}

@end
