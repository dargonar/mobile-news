//
//  XMLParser.h
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject

-(NSArray*)extractImagesAndRebuild:(NSData**)xml_data error:(NSError **)error prefix:(NSString*)prefix;
-(NSArray*)extractNewsUrls:(NSData*)xml_data error:(NSError **)error;
-(NSDictionary* )getAdImageAndUrl:(NSData**)xml_data error:(NSError **)error;
@end
