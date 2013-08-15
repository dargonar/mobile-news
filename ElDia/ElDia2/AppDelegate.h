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

@class MainViewController, MenuViewController, MenuClasificadosViewController, ClasificadosViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  NSOperationQueue  *download_queue;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
//@property (strong, nonatomic) MenuClasificadosViewController *menuClasificadosViewController;
@property (strong, nonatomic) ClasificadosViewController *menuClasificadosViewController;
@property (strong, nonatomic) ClasificadosViewController *clasificadosViewController;
@property (strong, nonatomic) ClasificadosViewController *farmaciaViewController;
@property (strong, nonatomic) ClasificadosViewController *carteleraViewController;
@property (strong, nonatomic) UINavigationController * navigationController;
@property (strong, nonatomic) NSOperationQueue *download_queue;;

- (void)showSideMenu;
- (void)hideSideMenu;
- (void)hideSideMenuPushMenuClasificados;
- (void)hideSideMenuPushClasificados;
- (void)hideSideMenuPushFunebres;

- (void)hideSideMenuPushFarmacia;
- (void)hideSideMenuPushCartelera;

//- (void)downloadImages:(NSArray *)mobi_images obj:(id)obj request_url:(NSString*)request_url;
- (void)requestDone:(ASIHTTPRequest *)request;
- (void)requestWentWrong:(ASIHTTPRequest *)request;

- (void)loadService:(NSURL*)url;
- (void)loadSectionNews:(NSURL*)url;
- (void)loadMenu:(BOOL)useCache;
- (void)loadClasificados:(NSURL*)url;
- (void)loadFunebres:(NSURL*)url;
- (void)loadFarmacia:(NSURL*)url;
- (void)loadCartelera:(NSURL*)url;
- (void)loadMenuClasificados:(NSURL*)url;

- (void)showClasificados;

- (BOOL)isiPad;
- (BOOL)isLandscape;

@end