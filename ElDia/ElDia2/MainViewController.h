//
//  MainViewController.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NoticiaViewController.h"
#import "YMobiPaperLib.h"

@interface MainViewController : UIViewController<UIWebViewDelegate, YMobiPaperLibDelegate>
{
  YMobiPaperLib *mYMobiPaperLib;
  NoticiaViewController *myNoticiaViewController;
}

@property (nonatomic, retain) IBOutlet UIButton *btnRefreshClick;
@property (nonatomic, retain) NoticiaViewController *myNoticiaViewController;
@property (nonatomic, retain)  YMobiPaperLib *mYMobiPaperLib;
@property (nonatomic, retain)  IBOutlet UIWebView *mainUIWebView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *refresh_loading_indicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;

@property (nonatomic, retain) IBOutlet UIImageView *logo_imgvw_alpha;
@property (nonatomic, retain) IBOutlet UIImageView *offline_imgvw;
@property (nonatomic, retain) IBOutlet UILabel *offline_lbl;

@property (nonatomic, retain) IBOutlet UIImageView *welcome_imgvw;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *welcome_indicator;

- (IBAction) btnOptionsClick: (id)param;
- (IBAction) btnRefreshClick: (id)param;
-(void) loadNoticiaView;
-(void)loadSectionNews:(NSURL*)rawURL;
+(id)sharedInstance;

-(void) showRefreshLoadingIndicator;
-(void) showMainLoadingIndicator;
-(void) showWelcomeLoadingIndicator;
-(void) hideLoadingIndicator;
-(void) hideRefreshLoadingIndicator;

-(void) firstTimeUseGone;
-(bool) isFirstTimeUse;

-(void)loadIndex:(BOOL)force_load;
-(void)loadLastKnownIndex;
//~/Library/Application Support/iPhone Simulator/

@end
