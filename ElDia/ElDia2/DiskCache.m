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
BOOL      init_ok = NO;

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
  if(!init_ok) return nil;

  if(![self exists:key prefix:prefix])
    return nil;
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager contentsAtPath:[self getFileName:key prefix:prefix]];
}

-(BOOL)put:(NSString*)key data:(NSData*)data prefix:(NSString*)prefix{
  if(!init_ok) return NO;

  NSString* file=[self getFileName:key prefix:prefix];
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager createFileAtPath:file contents:data attributes:nil];
}

-(BOOL)remove:(NSString*)key prefix:(NSString*)prefix{
  if(!init_ok) return NO;

  NSString* file=[self getFileName:key prefix:prefix];
  NSFileManager *fileManager= [NSFileManager defaultManager];

  NSError *err = nil;
  return [fileManager removeItemAtPath:file error:&err];
}

-(BOOL)exists:(NSString *)key prefix:(NSString *)prefix {
  if(!init_ok) return NO;
  
  NSString* file=[self getFileName:key prefix:prefix];
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager fileExistsAtPath:file isDirectory:nil];
}

-(NSString*)getFolder{
  if(!init_ok) return nil;
  return cache_folder;
}

-(NSURL*)getFolderUrl{
  if(!init_ok) return nil;
  return [[NSURL alloc] initFileURLWithPath:cache_folder isDirectory:YES];
}

-(void) create_folder:(NSString*)folder_name
{
  init_ok = YES;
  
  BOOL isDir;
  NSFileManager *fileManager= [NSFileManager defaultManager];

  //Existe y es un folder?
  BOOL exists = [fileManager fileExistsAtPath:folder_name isDirectory:&isDir];
  if(exists && isDir)
    return;
  
  //No existe y lo creo ok?
  if([fileManager createDirectoryAtPath:folder_name withIntermediateDirectories:YES attributes:nil error:NULL])
    return;
  
  //No pudimos inicializar / no hay cache
  init_ok = NO;
}

-(void)configure:(NSString*)root_dir cache_size:(int)cache_size {
  
  max_size     = cache_size;
  cache_folder = [NSString stringWithFormat:@"%@/%@",root_dir,CACHE_FOLDER];
  
  [self create_folder:cache_folder];
  
}

-(NSDate *)createdAt:(NSString*)key prefix:(NSString*)prefix{
  if(!init_ok) return nil;
  
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
  if(!init_ok) return 0;
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
  if(!init_ok) return;  
}


@end
