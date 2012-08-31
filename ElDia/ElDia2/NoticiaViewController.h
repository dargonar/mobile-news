//
//  NoticiaViewController.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSWebView.h"

@interface NoticiaViewController : UIViewController<UIWebViewDelegate, UIGestureRecognizerDelegate> /*{
	 PSWebView 			*mainUIWebView;
  }*/


@property (nonatomic, retain)  IBOutlet UIView *bottomUIView;
@property (nonatomic, retain)  IBOutlet PSWebView *mainUIWebView;
@property (nonatomic, retain)  IBOutlet UIImageView *optionsBottomMenuUIImageView;
- (IBAction) btnBackClick: (id)param;
- (IBAction) btnShareClick: (id)param;


@end
