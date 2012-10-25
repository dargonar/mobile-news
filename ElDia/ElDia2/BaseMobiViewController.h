//
//  BaseMobiViewController.h
//  ElDia
//
//  Created by Lion User on 25/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iToast.h"
#import "ScreenManager.h"

@interface BaseMobiViewController : UIViewController{
  ScreenManager *mScreenManager;
}

@property (nonatomic, retain) ScreenManager *mScreenManager;

-(void)configureToast;
-(BOOL)isOld:(NSDate*)date;

@end
