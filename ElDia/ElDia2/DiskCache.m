//
//  DiskCache.m
//  ElDia
//
//  Created by Lion User on 23/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "DiskCache.h"
#define CACHE_FOLDER @"mobipaper_cache"

@implementation DiskCache


NSString* cache_folder;


+ (DiskCache *) defaultCache
{
  static DiskCache *defaultCache = NULL;
  @synchronized(self)
  {
    if(defaultCache == NULL)
      defaultCache = [[DiskCache alloc] init];
  }
  
  return defaultCache;
}

-(NSString*)getFileName:(NSString*)key prefix:(NSString*)prefix{
  return [NSString stringWithFormat:@"%@/%@_%@", cache_folder, prefix, key];
  
}

-(NSString*)getString:(NSString*)key prefix:(NSString*)prefix{
  if(![self file_exists:key prefix:prefix])
    return nil;
  
  return [NSString stringWithContentsOfFile:[self getFileName:key prefix:prefix] encoding:NSUTF8StringEncoding error:nil];
}


-(NSData*)getData:(NSString*)key prefix:(NSString*)prefix{
  if(![self file_exists:key prefix:prefix])
    return nil;
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager contentsAtPath:[self getFileName:key prefix:prefix]];
}

-(void)store:(NSString*)key data:(NSData*)data prefix:(NSString*)prefix{
  NSString* file=[self getFileName:key prefix:prefix];
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  [fileManager createFileAtPath:file contents:data attributes:nil];
  
  fileManager=nil;
  file=nil;

}

-(BOOL)file_exists:(NSString*)key prefix:(NSString*)prefix{
  NSString* file=[self getFileName:key prefix:prefix];
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager fileExistsAtPath:file isDirectory:nil];
}


-(void) create_folder:(NSString*)folder_name
{
  BOOL isDir=YES;
  NSFileManager *fileManager= [NSFileManager defaultManager];
  if(![fileManager fileExistsAtPath:folder_name isDirectory:&isDir])
    if(![fileManager createDirectoryAtPath:folder_name withIntermediateDirectories:YES attributes:nil error:NULL])
      NSLog(@"Error: Create folder failed %@", folder_name);
  fileManager=nil;

}


-(void)configure:(NSString*)root_dir{
  
  cache_folder=[NSString stringWithFormat:@"%@/%@",root_dir,CACHE_FOLDER];
  [self create_folder:cache_folder];
  
}

@end
