//
//  ConfigHelper.m
//  ElDia2
//
//  Created by Lion User on 03/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "ConfigHelper.h"




@implementation ConfigHelper

/*
- (id)init{
	
	if (self = [super init]) {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
  }
  return self;
}
*/

+(void)configure:(NSData*)data{

}

+(NSString *)getSettingValue:(NSString*)key{
  return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(void)setSettingValue:(NSString*)key value:(NSString*)value{
  NSUserDefaults *settings=[NSUserDefaults standardUserDefaults];
  [settings setObject:value forKey:key];
  [settings synchronize];
  settings=nil;
}

/*
 [[NSUsererDefaults standardUserDefaults] setObject:myObject forKey:@"myObjectKey"].
 
 To read the data call [[NSUserDefaults standardUserDefaults] objectForKey:@"myObjectKey"]
 */
@end
