//
//  YoutubeController.m
//  UiwebViewCrash
//
//  Created by Mikael Konradsson on 2012-03-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoutubeController.h"
#import "youtubePlayer.h"

@interface YoutubeController() {
	YoutubePlayer *player;
}
@end

@implementation YoutubeController
@synthesize video_id;

- (void)dealloc {
    player = nil;
  //[super dealloc];
}

- (YoutubePlayer*)player {
	if (player == nil) {
		CGRect r = [[UIScreen mainScreen] applicationFrame];
		player = [[YoutubePlayer alloc] initWithFrame:r];
	}
	return player;
}

- (void) loadView {
	[super loadView];
	[self setView:[self player]];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
    //[[self player] loadVideo];
    [[self player] loadVideoInFrame:self.view.frame video_id:self.video_id];  // Added by Claes J
}



@end
