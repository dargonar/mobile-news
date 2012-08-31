//
//  AppDelegate.h
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>

#define app_delegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@class MainViewController, MenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController * navigationController;

- (void)showSideMenu;
- (void)hideSideMenu;


@end