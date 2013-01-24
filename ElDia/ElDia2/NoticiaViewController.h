//
//  NoticiaViewController.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSWebView.h"
#import "FGalleryViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BaseMobiViewController.h"
#import "YoutubeViewController.h"
#import "TapDetectingWindow.h"



@interface NoticiaViewController : BaseMobiViewController<UIWebViewDelegate, UIGestureRecognizerDelegate,  FGalleryViewControllerDelegate, TapDetectingWindowDelegate>  {
	NSArray *networkCaptions;
  NSArray *networkImages;
	FGalleryViewController *networkGallery;
  
  NSString *noticia_id;
  NSString *noticia_url;
  NSString *noticia_title;
  NSString *noticia_header;

  YoutubeViewController *myYoutubeViewController;
  NSString* currentSection;
  
  TapDetectingWindow *mWindow;
}


@property (nonatomic, retain) YoutubeViewController *myYoutubeViewController;

@property (retain) NSString *noticia_id;
@property (retain) NSString *noticia_url;
@property (retain) NSString *noticia_title;
@property (retain) NSString *noticia_header;

@property (nonatomic, retain) IBOutlet UIView *bottomUIView;
//@property (nonatomic, retain) IBOutlet PSWebView *mainUIWebView;
@property (nonatomic, retain) IBOutlet UIWebView *mainUIWebView;
@property (nonatomic, retain) IBOutlet UIWebView *menu_webview;
@property (nonatomic, retain) IBOutlet UIImageView *optionsBottomMenuUIImageView;
@property (nonatomic, retain) IBOutlet UIImageView *headerUIImageView;
@property (nonatomic, retain) IBOutlet UIButton *btnFontSizePlus;
@property (nonatomic, retain) IBOutlet UIButton *btnFontSizeMinus;

@property (nonatomic, retain) IBOutlet UIView *offline_view;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;

- (IBAction) btnBackClick: (id)param;
- (IBAction) btnShareClick: (id)param;
- (IBAction) btnFontSizePlusClick: (id)param;
- (IBAction) btnFontSizeMinusClick: (id)param;

- (void)loadNoticia:(NSURL *)url section:(NSString*)section;
- (void)loadBlank;

@end
