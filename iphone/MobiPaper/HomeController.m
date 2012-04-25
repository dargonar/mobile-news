//
//  ViewController.m
//  MobiPaper
//
//  Created by Matias on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeController.h"

@interface HomeController ()

@end

@implementation HomeController
@synthesize webview;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *urlString = @"http://ymobipaper.appspot.com";
    NSURL* url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self loadUrlIntoWebView:url];
}

- (void)viewDidUnload
{
    [self setWebview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void) loadUrlIntoWebView:(NSURL*)url {
    
    [appDelegate showLoading:1];

    if(![appDelegate isDataSourceAvailable])
    {
        [appDelegate showLoading:0];
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Alerta" message:@"Sin conexión, verifique que este conectado a la red." 
                              delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSLog(@"%@", [url absoluteString]);
    
    NSURLRequest *urlrequest = [[NSURLRequest alloc] initWithURL:url];
    [webview loadRequest:urlrequest];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //if(navigationType==UIWebViewNavigationTypeLinkClicked)
    //{
    //    return NO;
    //}
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [appDelegate showLoading:1];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [appDelegate showLoading:0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [appDelegate showLoading:0];
    NSLog(@"Error %@",[error localizedDescription]);
}

@end
