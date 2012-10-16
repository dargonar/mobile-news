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
#import "YMobiPaperLib.h"

@interface MenuViewController: UIViewController<UIWebViewDelegate,UIGestureRecognizerDelegate>{
  YMobiPaperLib *mYMobiPaperLib;
}

@property (nonatomic, retain)  YMobiPaperLib *mYMobiPaperLib;
@property (strong, nonatomic) IBOutlet UIImageView *screenShotImageView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIImage *screenShotImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

- (void)slideThenHide;
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer ;
- (IBAction) btnCloseClick: (id)param;
- (void)adjustWebViewWidth:(CGFloat)_width;
- (void)setHtmlToView:(NSData*)data;
@end
