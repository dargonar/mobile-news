//
//  Htmlview.m
//  spelnyheterna
//
//  Created by Mikael Konradsson on 2012-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "youtubePlayer.h"

@implementation YoutubePlayer

- (void)dealloc {
	
	[self loadHTMLString:@"" 
				 baseURL:nil];
  //[super dealloc];
}

- (void) loadVideo {
	NSString *str = [NSString stringWithFormat:@"<html><head></head>"
	"<body style='margin:0'>" 
	"<iframe class=\"youtube-player\" type=\"text/html\" width=\"%d\" height=\"%d\" src=\"%@\" frameborder=\"0\">" 
	"</iframe>" 
	"</body>", 320, 200, @"http://www.youtube.com/embed/BVUMPrv8oRw"];
	
	[self loadHTMLString:str baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
}


// Added by Claes J

- (void) loadVideoInFrame:(CGRect)frame video_id:(NSString*)video_id{
	
    NSString *str = [NSString stringWithFormat:@"<html><head></head>"
                     "<body style='margin:0'>" 
                     "<iframe class=\"youtube-player\" type=\"text/html\" width=\"%f\" height=\"%f\" src=\"%@\" frameborder=\"0\">" 
                     "</iframe>" 
                     "</body>", frame.size.width, frame.size.height, [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", video_id]];
	
	[self loadHTMLString:str baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
}


@end
