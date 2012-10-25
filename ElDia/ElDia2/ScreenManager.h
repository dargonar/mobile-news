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

-(NSData *)getSection:(NSString*)url useCache:(BOOL)useCache error:(NSError**)error;
-(NSData *)getArticle:(NSString*)url useCache:(BOOL)useCache error:(NSError**)error;
-(NSData *)getMenu:(BOOL)useCache error:(NSError **)error;

-(NSDate*) sectionDate:(NSString*)url ;
  
-(NSArray *)getPendingImages:(NSString*)url error:(NSError**)error;

@end
