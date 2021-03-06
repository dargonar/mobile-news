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
-(BOOL) menuExists;
-(BOOL) menuClasificadosExists:(NSString*)url;
-(BOOL) clasificadosExists:(NSString*)url;
-(BOOL) funebresExists:(NSString*)url;
-(BOOL) farmaciaExists:(NSString*)url;
-(BOOL) carteleraExists:(NSString*)url;
-(BOOL) sectionMenuExists:(NSString*)url;

-(NSData *)getFarmacia:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error;
-(NSData *)getCartelera:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error;
-(NSData *)getMenuClasificados:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error;
-(NSData *)getClasificados:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error;
-(NSData *)getFunebres:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error;
-(NSData *)getSection:(NSString*)url useCache:(BOOL)useCache error:(NSError**)error;
-(NSData *)getArticle:(NSString*)url useCache:(BOOL)useCache error:(NSError**)error;
-(NSData *)getMenu:(BOOL)useCache error:(NSError **)error;

-(NSData *)getSectionMenu:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error;

-(NSDate*) sectionDate:(NSString*)url;  
-(NSDate*) menuClasificadosDate:(NSString*)url ;
-(NSDate*) clasificadosDate:(NSString*)url ;
-(NSDate*) funebresDate:(NSString*)url ;

-(NSDate*) farmaciaDate:(NSString*)url ;
-(NSDate*) carteleraDate:(NSString*)url ;

-(NSArray *)getPendingImages:(NSString*)url error:(NSError**)error;

+(BOOL)isMainScreenPrefix:(NSString*)prefix;
@end
