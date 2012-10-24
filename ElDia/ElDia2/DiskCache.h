//
//  DiskCache.h
//  ElDia
//
//  Created by Lion User on 23/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiskCache : NSObject


-(NSString*)getKey:(NSString*)key can_delete:(BOOL)can_delete;
-(NSString*)getString:(NSString*)key can_delete:(BOOL)can_delete;
-(NSData*)getData:(NSString*)key can_delete:(BOOL)can_delete;
-(void)store:(NSString*)key data:(NSData*)data can_delete:(BOOL)can_delete;
-(BOOL)file_exists:(NSString*)key can_delete:(BOOL)can_delete;
-(void) create_folder:(NSString*)folder_name;
-(void)configure:(NSString*)root_dir;

@end
