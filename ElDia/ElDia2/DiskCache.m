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
int       max_size;

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

-(NSData*)get:(NSString*)key prefix:(NSString*)prefix{
  if(![self exists:key prefix:prefix])
    return nil;
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager contentsAtPath:[self getFileName:key prefix:prefix]];
}

-(void)put:(NSString*)key data:(NSData*)data prefix:(NSString*)prefix{
  NSString* file=[self getFileName:key prefix:prefix];
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  [fileManager createFileAtPath:file contents:data attributes:nil];
  
  fileManager=nil;
  file=nil;
  
}

-(void)remove:(NSString*)key prefix:(NSString*)prefix{

  NSString* file=[self getFileName:key prefix:prefix];
  NSFileManager *fileManager= [NSFileManager defaultManager];

  NSError *err = nil;
  [fileManager removeItemAtPath:file error:&err];
}

-(BOOL)exists:(NSString *)key prefix:(NSString *)prefix {
  NSString* file=[self getFileName:key prefix:prefix];
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager fileExistsAtPath:file isDirectory:nil];
}

-(NSString*)getFolder{
  return cache_folder;
}

-(NSURL*)getFolderUrl{
  return [[NSURL alloc] initFileURLWithPath:cache_folder isDirectory:YES];
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


-(void)configure:(NSString*)root_dir cache_size:(int)cache_size {
  
  max_size     = cache_size;
  cache_folder = [NSString stringWithFormat:@"%@/%@",root_dir,CACHE_FOLDER];
  
  [self create_folder:cache_folder];
  
}

-(NSDate *)createdAt:(NSString*)key prefix:(NSString*)prefix{

  NSFileManager *fileManager= [NSFileManager defaultManager];
  NSString* fileName=[self getFileName:key prefix:prefix];
  if(![self exists:key prefix:prefix])
  {
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:0];
    return date; //[NSDate dateWithTimeIntervalSince1970:0];
  }
  
  NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:fileName error:nil];
  if(fileDictionary==nil)
    return [NSDate dateWithTimeIntervalSince1970:0];
  
  NSDate * date = [fileDictionary fileCreationDate];
  return date;
}

-(unsigned long long) size {

  NSFileManager *fileManager= [NSFileManager defaultManager];
  
  NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:cache_folder error:nil];
  NSEnumerator *filesEnumerator = [filesArray objectEnumerator];

  NSString *fileName;
  unsigned long long totalSize = 0;
  
  while (fileName = [filesEnumerator nextObject]) {

    if ([fileName hasPrefix:@"i_"] || [fileName hasPrefix:@"a_"] || [fileName hasPrefix:@"mi_"] ) {
      NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[cache_folder stringByAppendingPathComponent:fileName] error:nil];
      totalSize += [fileDictionary fileSize];
    }
  }
  
  return totalSize;
}

-(void) purge {
  
}


@end
