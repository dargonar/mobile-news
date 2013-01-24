//
//  TapDetectingWindow.h
//  ElDia
//
//  Created by Davo on 1/24/13.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TapDetectingWindowDelegate
- (void)userDidTapWebView:(id)tapPoint;
@end

@interface TapDetectingWindow : UIWindow {
  UIView *viewToObserve;
  __unsafe_unretained id <TapDetectingWindowDelegate> controllerThatObserves;
}
@property (nonatomic, retain) UIView *viewToObserve;
@property (nonatomic, assign) id <TapDetectingWindowDelegate> controllerThatObserves;
@end