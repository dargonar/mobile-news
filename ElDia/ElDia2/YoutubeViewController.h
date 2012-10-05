//
//  YoutubeViewController.h
//  ElDia2
//
//  Created by Lion User on 25/09/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YoutubeViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *mainUIWebView;

- (IBAction) btnBackClick: (id)param;
- (IBAction) btnShareClick: (id)param;
-(void) loadVideo:(NSString*)key req:(NSURLRequest*)req;
@end
