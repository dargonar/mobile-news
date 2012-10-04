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
#import "YMobiPaperLib.h"
#import "YoutubeViewController.h"


@interface NoticiaViewController : UIViewController<UIWebViewDelegate, UIGestureRecognizerDelegate, YMobiPaperLibDelegate, FGalleryViewControllerDelegate>  {
	NSArray *networkCaptions;
  NSArray *networkImages;
	FGalleryViewController *networkGallery;
  YoutubeViewController* myYoutubeViewController;
  
  NSString *noticia_id;
  YMobiPaperLib *mYMobiPaperLib;
}

@property (nonatomic, retain) YoutubeViewController *myYoutubeViewController;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) IBOutlet UIView *bottomUIView;
@property (nonatomic, retain) IBOutlet PSWebView *mainUIWebView;
@property (nonatomic, retain) IBOutlet UIImageView *optionsBottomMenuUIImageView;
@property (nonatomic, retain) IBOutlet UIButton *btnFontSizePlus;
@property (nonatomic, retain) IBOutlet UIButton *btnFontSizeMinus;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;
@property (nonatomic, retain)  YMobiPaperLib *mYMobiPaperLib;

- (IBAction) btnBackClick: (id)param;
- (IBAction) btnShareClick: (id)param;

- (IBAction) btnFontSizePlusClick: (id)param;
- (IBAction) btnFontSizeMinusClick: (id)param;

- (void)loadPhotoGallery: (NSURL *)_url;
- (void)playAudio: (NSURL *)_url;
- (void)playVideo: (NSURL *)_url;
- (NSString *)getYoutubeVideoId:(NSString*)url;
- (void)loadNoticia:(NSString *)_noticia_id;

- (void)addGestureRecognizers;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
- (void)handleRightSwipe :(UISwipeGestureRecognizer *)gesture;
- (void)handleLeftSwipe :(UISwipeGestureRecognizer *)gesture;
@end
