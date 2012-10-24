//
//  XMLParser.h
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject

-(NSArray*)getImagesURLs:(NSData*)xml_data;
@end
