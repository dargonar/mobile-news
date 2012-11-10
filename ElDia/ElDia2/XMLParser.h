//
//  XMLParser.h
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject

-(NSArray*)extractImagesAndRebuild:(NSData**)xml_data error:(NSError**)error;
-(NSArray*)extractNewsUrls:(NSData**)xml_data error:(NSError **)error;
@end
