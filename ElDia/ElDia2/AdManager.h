//
//  AdManager.h
//  ElDia
//
//  Created by Davo on 5/20/13.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdManager : NSObject

-(NSDictionary*)getSAdImage;
-(NSDictionary*)getMAdImage;
-(NSDictionary*)getLAdImage;
-(NSString*)getImageUrl:(NSDictionary*)dict;
-(NSString*)getClickUrl:(NSDictionary*)dict;
@end
