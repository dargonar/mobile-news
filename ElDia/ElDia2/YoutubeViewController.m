//
//  YoutubeViewController.m
//  ElDia2
//
//  Created by Lion User on 25/09/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "YoutubeViewController.h"
#import "AppDelegate.h"

@implementation YoutubeViewController


- (IBAction) btnBackClick: (id)param{
  [self.view removeFromSuperview];
//  [[app_delegate navigationController] popViewControllerAnimated:YES];
}

- (IBAction) btnShareClick: (id)param{}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
