//
//  AppDelegate.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

#define app_delegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@class MainViewController, MenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  NSOperationQueue  *download_queue;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController * navigationController;
@property (strong, nonatomic) NSOperationQueue *download_queue;;


- (void)showSideMenu;
- (void)hideSideMenu;
- (void)downloadImages:(NSArray *)mobi_images;
- (void)requestDone:(ASIHTTPRequest *)request;
- (void)requestWentWrong:(ASIHTTPRequest *)request;

@end