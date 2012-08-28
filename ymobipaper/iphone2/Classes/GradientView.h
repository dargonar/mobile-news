//
//  GradientView.h
//  Massa
//
//  Created by Davo on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GradientView : UIView {
	CGGradientRef _gradientLayer;
}
- (CGGradientRef)gradientLayer;

@end
