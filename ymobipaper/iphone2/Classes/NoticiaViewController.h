//
//  NoticiaViewController.h
//  Massa
//
//  Created by Lion User on 23/08/2012.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticiaViewController : UIViewController<UIWebViewDelegate> {
	UIWebView								*webView;
  UIActivityIndicatorView	*loading;
  UILabel									*label;
  UILabel									*msgerror;
  
  NSArray									*urls;
  
   
}

@property (nonatomic, retain) IBOutlet UIWebView 								*webView;
@property (nonatomic, retain) IBOutlet UILabel  								*label;
@property (nonatomic, retain) IBOutlet UILabel  								*msgerror;

@property (nonatomic, retain) IBOutlet UIButton  								*btnRight;
@property (nonatomic, retain) IBOutlet UIButton  								*btnLeft;
@property (nonatomic, retain) IBOutlet UIView  								  *viewLoadingBack;


- (IBAction) btnRightClick: (id)param;
- (IBAction) btnLeftClick: (id)param;
//- (NSURLRequest*) requestFor: (NSString*)location;
- (void) loadWith: (NSString*)id_or_url ;
@end
