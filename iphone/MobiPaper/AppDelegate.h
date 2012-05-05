//
//  AppDelegate.h
//  MobiPaper
//
//  Created by Matias on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeController;
@class MBProgressHUD;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MBProgressHUD* HUD;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HomeController *homeController;

- (BOOL)     isDataSourceAvailable;
- (void)     showLoading:(BOOL)show;

@end
