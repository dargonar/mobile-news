//
//  MassaAppDelegate.h
//  Massa
//
//  Created by Davo on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MassaViewController;

@interface MassaAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MassaViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MassaViewController *viewController;

@end

