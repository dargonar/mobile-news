//
//  DiskCache.h
//  ElDia
//
//  Created by Lion User on 23/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiskCache : NSObject

+ (DiskCache *) defaultCache;

-(void)configure:(NSString*)root_dir cache_size:(int)cache_size;
  
-(NSData*)   get:(NSString*)key prefix:(NSString*)prefix;
-(BOOL)      put:(NSString*)key data:(NSData*)data prefix:(NSString*)prefix;
-(BOOL)      remove:(NSString*)key prefix:(NSString*)prefix;
-(BOOL)      exists:(NSString*)key prefix:(NSString*)prefix;
-(BOOL)      put2:(NSString*)filename data:(NSData*)data;
-(NSDate *)createdAt:(NSString*)key prefix:(NSString*)prefix;

-(unsigned long long) size;
-(void)      purge;

-(NSString*) getFolder;
-(NSURL*)    getFolderUrl;

-(NSString*)getFileName:(NSString*)key prefix:(NSString*)prefix;
-(NSString*)getFileName2:(NSString*)key;
//-(NSString*)getFileName2:(NSString*)filename postfix:(NSString*)postfix;
-(BOOL)put2:(NSString*)key data:(NSData*)data postfix:(NSString*)postfix;

@end
