//
//  MassaViewController.h
//  Massa
//
//  Created by Davo on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticiaViewController.h"

@interface MassaViewController : UIViewController<UITabBarDelegate, UIWebViewDelegate> {
	UIWebView								*webView;
	UITabBar  							*tabBar;
  UIActivityIndicatorView	*loading;
  UILabel									*label;
  UILabel									*msgerror;
  
  NSArray									*urls;
  
  NoticiaViewController *myNoticiaViewController;
}

@property (nonatomic, retain) IBOutlet UIWebView 								*webView;
@property (nonatomic, retain) IBOutlet UITabBar  								*tabBar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView  *loading;
@property (nonatomic, retain) IBOutlet UILabel  								*label;
@property (nonatomic, retain) IBOutlet UILabel  								*msgerror;

@property (nonatomic, retain) IBOutlet UIButton  								*btnRight;
@property (nonatomic, retain) IBOutlet UIButton  								*btnLeft;
@property (nonatomic, retain) IBOutlet UIView  								  *viewLoadingBack;

@property (nonatomic, retain) NoticiaViewController *myNoticiaViewController;

- (IBAction) btnRightClick: (id)param;
- (IBAction) btnLeftClick: (id)param;
- (NSURLRequest*) requestFor: (NSString*)location;

@end

