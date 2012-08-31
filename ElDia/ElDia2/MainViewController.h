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

@interface MainViewController : UIViewController<UIWebViewDelegate>
{
  YMobiPaperLib *mYMobiPaperLib;
  NoticiaViewController *myNoticiaViewController;
}

@property (nonatomic, retain) NoticiaViewController *myNoticiaViewController;
@property (nonatomic, retain)  YMobiPaperLib *mYMobiPaperLib;
@property (nonatomic, retain)  IBOutlet UIWebView *mainUIWebView;
- (IBAction) btnOptionsClick: (id)param;
- (IBAction) btnRefreshClick: (id)param;


@end
