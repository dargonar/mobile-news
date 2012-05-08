//
//  MassaViewController.h
//  Massa
//
//  Created by Davo on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MassaViewController : UIViewController<UITabBarDelegate, UIWebViewDelegate> {
	UIWebView								*webView;
	UITabBar  							*tabBar;
  UIActivityIndicatorView	*loading;
  UILabel									*label;
  UILabel									*msgerror;
  
  NSArray									*urls;
  
}

@property (nonatomic, retain) IBOutlet UIWebView 								*webView;
@property (nonatomic, retain) IBOutlet UITabBar  								*tabBar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView  *loading;
@property (nonatomic, retain) IBOutlet UILabel  								*label;
@property (nonatomic, retain) IBOutlet UILabel  								*msgerror;

@property (nonatomic, retain) UITableView *seccionesView;

- (NSURLRequest*) requestFor: (NSString*)location;

@end

