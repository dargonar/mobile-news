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
  return [NSString stringWithFormat:@"%@/%@.%@", cache_folder, key, prefix];
}

-(NSString*)getFileName2:(NSString*)filename{
  return [NSString stringWithFormat:@"%@/%@", cache_folder, filename];
}

-(NSData*)get:(NSString*)key prefix:(NSString*)prefix{
  if(!init_ok) return nil;

  if(![self exists:key prefix:prefix])
  {
    return nil;
  }
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager contentsAtPath:[self getFileName:key prefix:prefix]];
}

-(BOOL)put:(NSString*)key data:(NSData*)data prefix:(NSString*)prefix{
  if(!init_ok) return NO;

//  NSLog(@" SAVED [%@_%@]", prefix, key);
  NSString* file=[self getFileName:key prefix:prefix];
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager createFileAtPath:file contents:data attributes:nil];
}

-(BOOL)put2:(NSString*)filename data:(NSData*)data{
  if(!init_ok) return NO;
  
  //  NSLog(@" SAVED [%@_%@]", prefix, key);
  NSString* file=[self getFileName2:filename];
  
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
//  BOOL serungo = [fileManager fileExistsAtPath:file isDirectory:nil];
//  NSLog(@" %@ EXISTS [%@_%@]",(serungo==YES?@"SI":@"NO"), prefix, key);
//  return serungo;
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

    if ([fileName hasPrefix:@"i_"] || [fileName hasPrefix:@"a_"] || [fileName hasPrefix:@"mi_"] || [fileName hasPrefix:@"c_"]) {
      NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[cache_folder stringByAppendingPathComponent:fileName] error:nil];
      totalSize += [fileDictionary fileSize];
    }
  }
  
  return totalSize;
}



-(void) purge {
  if(!init_ok) return;
  
  unsigned long long size = [self size];
  unsigned long long max_size_bytes =max_size*1024*1024;
  
  if(size < max_size_bytes)
  {
    NSLog(@" Current Cache size: (%llu)bytes is OK", size);
    return;
  }
  
  NSLog(@" Curret Cache Size:  %lld bytes", size);
  
  unsigned long long removeBytes = size-(unsigned long long)(max_size_bytes*0.25);
  [self shrinkCache:removeBytes];
}

-(void)shrinkCache:(unsigned long long)removeBytes {
  
  NSLog(@" Size to purge:  %lld bytes", removeBytes);
  
  NSFileManager *manager = [NSFileManager defaultManager];
  
  NSString* expandedPath = [cache_folder stringByExpandingTildeInPath];
  
  NSError* error = nil;
  NSArray* filesArray = [manager contentsOfDirectoryAtPath:expandedPath error:&error];
  if(error != nil) {
    NSLog(@"Error in reading files: %@", [error localizedDescription]);
    return;
  }
  
  // sort by creation date
  NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
  for(NSString* file in filesArray) {
    NSString* filePath = [expandedPath stringByAppendingPathComponent:file];
    NSDictionary* properties = [[NSFileManager defaultManager]
                                attributesOfItemAtPath:filePath
                                error:&error];
    NSDate* modDate = [properties objectForKey:NSFileModificationDate];
    
    if(error == nil)
    {
      [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     file, @"path",
                                     modDate, @"lastModDate",
                                     nil]];
    }
  }
  
  // sort using a block
  // order inverted as we want latest date first
  NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                          ^(id path1, id path2)
                          {
                            // compare
                            NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                       [path2 objectForKey:@"lastModDate"]];
                            // invert ordering
                            if (comp == NSOrderedDescending) {
                              comp = NSOrderedAscending;
                            }
                            else if(comp == NSOrderedAscending){
                              comp = NSOrderedDescending;
                            }
                            return -1*comp;
                          }];
  
  //NSLog(@"SortedFiles: %@", sortedFiles);

  unsigned long long totalDeletedSize = 0;
  
  for(NSDictionary* file in sortedFiles) {
    NSString *fileName = (NSString *)[file objectForKey:@"path"];
    NSString *fileCreateDate = (NSString *)[file objectForKey:@"lastModDate"];
    if ([fileName hasSuffix:@".i"] || [fileName hasSuffix:@".a"] || [fileName hasSuffix:@".mi"] || [fileName hasSuffix:@".c"] || [fileName hasSuffix:@".zip"]) {
      NSDictionary *fileDictionary = [manager attributesOfItemAtPath:[expandedPath stringByAppendingPathComponent:fileName] error:nil];
      totalDeletedSize += [fileDictionary fileSize];
      [manager removeItemAtPath:[expandedPath stringByAppendingPathComponent:fileName] error:nil];
      
      NSLog(@" Deleted File: %@ -- %@", fileName, fileCreateDate);
      
      if(totalDeletedSize>=removeBytes)
        break;
    }
  }
  
  NSLog(@" Current Size :  %lld bytes", [self size]);
}

@end
