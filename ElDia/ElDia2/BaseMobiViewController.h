//
//  BaseMobiViewController.h
//  ElDia
//
//  Created by Lion User on 25/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenManager.h"
#import "MobiImage.h"

@interface BaseMobiViewController : UIViewController{
  ScreenManager   *mScreenManager;
}

@property (nonatomic, retain) ScreenManager *mScreenManager;
@property (nonatomic, retain) NSString* currentUrl;
@property (nonatomic, retain) UIWebView* myUIWebView;

-(void)configureToast;
-(BOOL)isOld:(NSDate*)date;
-(void)setHTML:(NSData*)data url:(NSString*)url webView:(UIWebView*)webView;
//-(void)showMessage:(NSString*)message;
-(void)showMessage:(NSString*)message isError:(BOOL)isError;
@end
