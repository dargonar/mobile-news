//
//  MenuViewController.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseMobiViewController.h"

@interface MenuViewController: BaseMobiViewController<UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *screenShotImageView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIImage *screenShotImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

- (IBAction) btnCloseClick: (id)param;
-(void)loadUrl:(BOOL)useCache;
//- (void)slideThenHide;
//- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer ;
//- (void)adjustWebViewWidth:(CGFloat)_width;

@end
