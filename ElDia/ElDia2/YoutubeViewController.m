//
//  YoutubeViewController.m
//  ElDia2
//
//  Created by Lion User on 25/09/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "YoutubeViewController.h"
#import "AppDelegate.h"
#import "DiskCache.h"

@implementation YoutubeViewController


- (IBAction) btnBackClick: (id)param{
  
  [self.view removeFromSuperview];
  
  //[[app_delegate navigationController] popViewControllerAnimated:YES];
}

- (IBAction) btnShareClick: (id)param{}


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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  self.mainUIWebView=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) loadVideo:(NSString*)key req:(NSURLRequest*) req{
  
  [self.mainUIWebView loadRequest:req];
  
  //CGRect r = [[UIScreen mainScreen] applicationFrame];
  
  /*CGRect r = self.view.frame;
  
  NSString *str = [NSString stringWithFormat:@"<html><head></head>"
                   "<body style='margin:0'>"
                   "<iframe class=\"youtube-player\" type=\"text/html\" width=\"%f\" height=\"%f\" src=\"%@\" frameborder=\"0\">"
                   "</iframe>"
                   "</body>", r.size.width, r.size.height, [[NSString alloc] initWithFormat:@"http://www.youtube.com/embed/%@", key]];
	
	[self.mainUIWebView loadHTMLString:str baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
  */
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  return YES;
}
@end
