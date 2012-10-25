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

-(NSDate *)createdAt:(NSString*)key prefix:(NSString*)prefix;

-(unsigned long long) size;
-(void)      purge;

-(NSString*) getFolder;
-(NSURL*)    getFolderUrl;
@end
