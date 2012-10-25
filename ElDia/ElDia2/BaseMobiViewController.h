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
  ScreenManager *mScreenManager;
}

@property (nonatomic, retain) ScreenManager *mScreenManager;
@property (nonatomic, retain)  IBOutlet UIWebView *mainUIWebView;
@property (nonatomic, retain) NSString* currentUrl;

-(void)configureToast;
-(BOOL)isOld:(NSDate*)date;
-(void)setHTML:(NSData*)data url:(NSString*)url;
-(void)onImageDownloaded:(MobiImage*)mobi_image url:(NSString*)url;
@end
