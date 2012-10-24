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

-(NSString*)getKey:(NSString*)key can_delete:(BOOL)can_delete{
  if(can_delete)
    return [NSString stringWithFormat:@"%@/d_%@",cache_folder, key];
  
  return [NSString stringWithFormat:@"%@/x_%@", cache_folder, key];
  
}

-(NSString*)getString:(NSString*)key can_delete:(BOOL)can_delete{
  if(![self file_exists:key can_delete:can_delete])
    return nil;
  
  return [NSString stringWithContentsOfFile:[self getKey:key can_delete:can_delete] encoding:NSUTF8StringEncoding error:nil];
}


-(NSData*)getData:(NSString*)key can_delete:(BOOL)can_delete{
  if(![self file_exists:key can_delete:can_delete])
    return nil;
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  return [fileManager contentsAtPath:[self getKey:key can_delete:can_delete]];
}

-(void)store:(NSString*)key data:(NSData*)data can_delete:(BOOL)can_delete{
  NSString* file=[self getKey:key can_delete:can_delete];
  
  NSFileManager *fileManager= [NSFileManager defaultManager];
  [fileManager createFileAtPath:file contents:data attributes:nil];
  
  fileManager=nil;
  file=nil;

}

-(BOOL)file_exists:(NSString*)key can_delete:(BOOL)can_delete{
  NSString* file=[self getKey:key can_delete:can_delete];
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
