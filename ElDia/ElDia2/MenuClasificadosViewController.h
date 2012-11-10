//
//  MenuClasificadosViewController.h
//  ElDia
//
//  Created by Davo on 11/9/12.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMobiViewController.h"
#import "ClasificadosViewController.h"

@interface MenuClasificadosViewController : BaseMobiViewController<UIWebViewDelegate>

@property (strong, nonatomic) ClasificadosViewController *clasificadosViewController;
@property (nonatomic, retain) IBOutlet UIWebView *mainUIWebView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;

@end
