//
//  MainViewController.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticiaViewController.h"
#import "BaseMobiViewController.h"

/*
 SKU99-0001-20121112
 Bundle IDcom.diventi.mobipaper
 Apple ID
 578331790
 Type
 iOS App
 Default LanguageSpanish
 */

@interface MainViewController : BaseMobiViewController<UIWebViewDelegate>
{
  NoticiaViewController *myNoticiaViewController;
  NSString* current_url;
}

@property (nonatomic, retain) NoticiaViewController *myNoticiaViewController;

@property (nonatomic, retain)  IBOutlet UIWebView *mainUIWebView;
@property (nonatomic, retain)  IBOutlet UIWebView *menu_webview;

@property (nonatomic, retain) IBOutlet UIButton *btnOptions;
@property (nonatomic, retain) IBOutlet UIButton *btnRefreshClick;
@property (nonatomic, retain) IBOutlet UIImageView *header;
@property (nonatomic, retain) IBOutlet UIImageView *logo;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *refresh_loading_indicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;

@property (nonatomic, retain) IBOutlet UIImageView *logo_imgvw_alpha;
@property (nonatomic, retain) IBOutlet UIView *offline_view;

@property (nonatomic, retain) IBOutlet UIView *welcome_view;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *welcome_indicator;
@property (nonatomic, retain) IBOutlet UIView *error_view;

@property (nonatomic, retain) IBOutlet UIButton *btnRefresh2;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *refresh_loading_indicator2;

- (IBAction) btnOptionsClick: (id)param;
- (IBAction) btnRefreshClick: (id)param;
- (IBAction) btnRefresh2Click: (id)param;

-(void)loadUrlAndLoading:(NSString*)url useCache:(BOOL)useCache;

// ~/Library/Application Support/iPhone Simulator/
// ~/Library/Developer/Xcode/DerivedData
/*
http://www.cocoawithlove.com/2009/01/multiple-virtual-pages-in-uiscrollview.html
*/


  
@end
