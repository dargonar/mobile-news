//
//  ClasificadosViewController.h
//  ElDia
//
//  Created by Lion User on 30/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMobiViewController.h"

@interface ClasificadosViewController : BaseMobiViewController<UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *mainUIWebView;
@property (nonatomic, retain) IBOutlet UIView *bottomUIView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading_indicator;

- (IBAction) btnBackClick: (id)param;
- (IBAction) btnShareClick: (id)param;
- (IBAction) btnFontSizePlusClick: (id)param;
- (IBAction) btnFontSizeMinusClick: (id)param;

- (void)loadClasificados:(NSURL *)url;
-(void)loadFunebres:(NSURL *)url;
-(void)loadFarmacia:(NSURL *)url;
-(void)loadCartelera:(NSURL *)url;
@end
