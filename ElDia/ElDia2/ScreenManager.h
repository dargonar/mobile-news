//
//  ScreenManager.h
//  ElDia
//
//  Created by Matias on 10/24/12.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenManager : NSObject

-(BOOL) sectionExists:(NSString*)url;
-(BOOL) articleExists:(NSString*)url;

-(NSArray *)getSection:(NSString*)url useCache:(BOOL)useCache;
-(NSArray *)getArticle:(NSString*)url useCache:(BOOL)useCache;
@end
