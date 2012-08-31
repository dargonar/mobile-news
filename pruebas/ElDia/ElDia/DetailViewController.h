//
//  DetailViewController.h
//  ElDia
//
//  Created by Lion User on 26/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
