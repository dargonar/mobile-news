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
-(void)copyBundleResourcesTo:(NSString*)folder{
  
  
  NSString *sourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *destPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"includes"];
  
  [NSString stringWithFormat:@"%@/%@",root_dir,CACHE_FOLDER]
  
  NSArray* resContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:NULL];
  
  for (NSString* obj in resContents){
    NSError* error;
    if (![[NSFileManager defaultManager] copyItemAtPath:[sourcePath stringByAppendingPathComponent:obj] toPath:[destPath stringByAppendingPathComponent:obj]
                                                  error:&error])
      NSLog(@"Error: %@", error);;
  }
  
}
@end
