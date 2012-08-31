//
//  GradientView.m
//  Massa
//
//  Created by Davo on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GradientView.h"


@implementation GradientView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextDrawLinearGradient(context, self.gradientLayer, CGPointMake(0.0, 0.0),
                             CGPointMake(0.0, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
}


- (CGGradientRef)gradientLayer
{
  if (_gradientLayer == nil) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[] = { 0.0, 1.0 };
    CGFloat colors[] = {   0.0 / 255.0,   0.0 / 255.0,   0.0 / 255.0, 1.00, 
                           /*0.0 / 255.0,   0.0 / 255.0,   0.0 / 255.0, 1.00, */
                          34.0 / 255.0,  34.0 / 255.0,  34.0 / 255.0, 1.00 };
    
    _gradientLayer = CGGradientCreateWithColorComponents(colorSpace, colors, locations, sizeof(colors) / (sizeof(colors[0]) * 4));
    CGColorSpaceRelease(colorSpace);
  }
  return _gradientLayer;
}
  
- (void)dealloc {
  CGGradientRelease(_gradientLayer);
  [super dealloc];
}


@end
