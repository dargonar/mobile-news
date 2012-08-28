//
//  ViewController.h
//  ElDia
//
//  Created by Lion User on 26/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
  UIWebView *mainUIWebView;
}

@property (nonatomic, retain)  UIWebView *mainUIWebView;
- (IBAction) btnOptionsClick: (id)param;
- (IBAction) btnRefreshClick: (id)param;



@end
