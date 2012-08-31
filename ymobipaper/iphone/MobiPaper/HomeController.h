//
//  ViewController.h
//  MobiPaper
//
//  Created by Matias on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface HomeController : UIViewController<UIWebViewDelegate> {
    AppDelegate         *appDelegate;
}

@property (weak, nonatomic) IBOutlet UIWebView *webview;

-(void) loadUrlIntoWebView:(NSURL*)url;

@end
