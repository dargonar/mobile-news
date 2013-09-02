//
//  ConfigHelper.m
//  ElDia2
//
//  Created by Lion User on 03/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "ConfigHelper.h"
#import "DiskCache.h"
#import "JSONKit.h"
#import "AppDelegate.h"

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

// Recibe el NSData del archivo config.json. Lo itera y por cada key lo guarda.

+(BOOL)isConfigured{
  if([[NSUserDefaults standardUserDefaults] objectForKey:@"google_analytics"]==nil)
    return NO;
  return YES;
}
  
+(void)configure{
  
  NSData *content = [[DiskCache defaultCache] get:@"config" prefix:@"json"];
  
  if (content==nil) {
    return;
  }

  NSString*dartu= [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
  NSDictionary *deserializedData = [dartu objectFromJSONString];

//'android': { 'ad_mob': 'a1521debeb75556', 'google_analytics' : ['UA-32663760-4'] },
//'iphone':  { 'ad_mob': 'a1521debeb75556', 'google_analytics' : ['UA-32663760-4'] },
//'ipad':    { 'ad_mob': 'a1521debeb75556', 'google_analytics' : ['UA-32663760-4'] }

  NSString* device = @"iphone";
  if([app_delegate isiPad])
  {device = @"ipad";}

  NSString* google_analytics = @"";
  NSString* admob = [(NSDictionary *)[deserializedData objectForKey:device] objectForKey:@"ad_mob"];
  NSArray *ga = (NSArray *)[(NSDictionary *)[deserializedData objectForKey:device] objectForKey:@"google_analytics"];
  for (int i=0; i<[ga count]; i++) {
    if([google_analytics isEqual:@""]==NO)
    {
      google_analytics=[google_analytics stringByAppendingString:@","];
      google_analytics=[google_analytics stringByAppendingString:[ga objectAtIndex:i]];
    }
  }
  [ConfigHelper setSettingValue:@"admob" value:admob];
  [ConfigHelper setSettingValue:@"google_analytics" value:google_analytics];
}


+(NSArray *)getGATrackingCodes{
  NSString* gaTrackingCodes=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"google_analytics"];
  if(gaTrackingCodes==nil)
    return nil;
  if([gaTrackingCodes isEqualToString:@""])
    return nil;
  
  return [gaTrackingCodes componentsSeparatedByString:@","];
}

+(NSString *)getAdMobId{
  
  NSString* adMobId=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"admob"];
  if(adMobId==nil)
    return nil;
  return adMobId;
}


+(NSString *)getSettingValue:(NSString*)key{
  if([[NSUserDefaults standardUserDefaults] objectForKey:key]==nil)
    return nil;
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
