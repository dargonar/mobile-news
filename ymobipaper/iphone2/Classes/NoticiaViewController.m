//
//  NoticiaViewController.m
//  Massa
//
//  Created by Lion User on 23/08/2012.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import "NoticiaViewController.h"

@interface NoticiaViewController ()

@end

@implementation NoticiaViewController

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) btnRightClick: (id)param{}
- (IBAction) btnLeftClick: (id)param{}
//- (NSURLRequest*) requestFor: (NSString*)location{}
- (void) loadWith: (NSString*)id_or_url {

}


@end
