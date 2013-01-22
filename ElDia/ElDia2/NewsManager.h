//
//  NewsManager.h
//  ElDia
//
//  Created by Lion User on 29/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsManager : NSObject

+ (NewsManager *) defaultNewsManager;
-(void)setURLs:(NSArray*)array;
-(NSURL*)getNextNoticiaId:(NSString*)_noticia_id;
-(NSURL*)getPrevNoticiaId:(NSString*)_noticia_id;

@end
