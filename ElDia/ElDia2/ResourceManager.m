//
//  ResourceManager.m
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "ResourceManager.h"
#import "DiskCache.h"

@implementation ResourceManager

+(void)copyBundleResourcesToCacheFolder{
  
  
  NSString *sourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *destPath = [[DiskCache defaultCache] getCacheFolder];
  
  NSArray* resContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:NULL];
  
  BOOL checked = NO;
  for(int i=0;i<[resContents count];i++){
    
    NSString* path = (NSString*)[resContents objectAtIndex:i];
    if(!([path hasSuffix:@".jpg"]||[path hasSuffix:@".png"]||[path hasSuffix:@".gif"]||[path hasSuffix:@".jpeg"]||[path hasSuffix:@".css"]))
      continue;
    
    if(!checked)
    {
      NSArray *filenames = [path componentsSeparatedByString:@"/"];
      NSString* filename = (NSString*)[filenames objectAtIndex:([filenames count]-1) ];
      if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",destPath,filename]])
      {
        break;
      }
      else
      {
        checked=YES;
      }
    }
    
    NSError* error;
    if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:destPath error:&error])
      NSLog(@"Error: %@", error);
    
  }
  
}
@end
