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
#import <Socialize/Socialize.h>


@interface NoticiaViewController : BaseMobiViewController<UIWebViewDelegate, UIGestureRecognizerDelegate, FGalleryViewControllerDelegate>  {
	NSArray *networkCaptions;
  NSArray *networkImages;
	FGalleryViewController *networkGallery;
  
  NSString *noticia_id;
  NSString *noticia_url;
  NSString *noticia_title;
  NSString *noticia_header;

  YoutubeViewController *myYoutubeViewController;
}

// Socialize
@property (nonatomic, retain) SZActionBar *actionBar;
@property (nonatomic, retain) id<SZEntity> entity;

@property (nonatomic, retain) YoutubeViewController *myYoutubeViewController;

@property (retain) NSString *noticia_id;
@property (retain) NSString *noticia_url;
@property (retain) NSString *noticia_title;
@property (retain) NSString *noticia_header;

@property (nonatomic, retain) IBOutlet UIView *bottomUIView;
@property (nonatomic, retain) IBOutlet PSWebView *mainUIWebView;
@property (nonatomic, retain) IBOutlet UIImageView *optionsBottomMenuUIImageView;
@property (nonatomic, retain) IBOutlet UIImageView *headerUIImageView;
@property (nonatomic, retain) IBOutlet UIButton *btnFontSizePlus;
@property (nonatomic, retain) IBOutlet UIButton *btnFontSizeMinus;

@property (nonatomic, retain) IBOutlet UIImageView *offline_imgvw;
@property (nonatomic, retain) IBOutlet UILabel *offline_lbl;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;

- (IBAction) btnBackClick: (id)param;
- (IBAction) btnShareClick: (id)param;
- (IBAction) btnFontSizePlusClick: (id)param;
- (IBAction) btnFontSizeMinusClick: (id)param;

- (void)loadNoticia:(NSURL *)url;
- (void)loadBlank;

@end
