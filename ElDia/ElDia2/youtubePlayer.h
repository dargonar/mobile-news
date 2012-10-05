//
//  Htmlview.h
//  spelnyheterna
//
//  Created by Mikael Konradsson on 2012-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubePlayer : UIWebView {
	
}
- (void) loadVideo;
//- (void) loadVideoInFrame:(CGRect)frame;  // Added by Claes J
- (void) loadVideoInFrame:(CGRect)frame video_id:(NSString*)video_id;
@end
