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

-(NSString*) getKey:(NSString*)key prefix:(NSString*)prefix;
-(NSString*) getString:(NSString*)key prefix:(NSString*)prefix;
-(NSData*)   getData:(NSString*)key prefix:(NSString*)prefix;

-(void) store:(NSString*)key data:(NSData*)data prefix:(NSString*)prefix;
-(BOOL) file_exists:(NSString*)key prefix:(NSString*)prefix;
-(void) create_folder:(NSString*)folder_name;
-(void) configure:(NSString*)root_dir;

@end
