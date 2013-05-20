//
//  AdManager.m
//  ElDia
//
//  Created by Davo on 5/20/13.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import "AdManager.h"
#import "ASIHTTPRequest.h"
#import "ErrorBuilder.h"
#import "XMLParser.h"

NSString * const AD_URL_768x90          = @"http://ads.e-planning.net/eb/4/88a3/889762e18e482ea0?o=f&rnd=%d&th=6b666a3291cf192c&ma=1";
NSString * const AD_URL_468x60          = @"http://ads.e-planning.net/eb/4/88a3/ac9674bc2892e561?o=f&rnd=%d&th=f0f8f5c29dd7a5a7&ma=1";
NSString * const AD_URL_320x50          = @"http://ads.e-planning.net/eb/4/88a3/cf1589bbf69edd4b?o=f&rnd=%d&th=c74668cd981c555c&ma=1";

@implementation AdManager

-(NSString*)getImageUrl:(NSDictionary*)dict{
  if(dict==nil)
    return @"";
  return (NSString*)[dict objectForKey:@"ad_url"];
}

-(NSString*)getClickUrl:(NSDictionary*)dict{
  if(dict==nil)
    return @"";
  return (NSString*)[dict objectForKey:@"click_url"];
}

-(NSDictionary*)getLAdImage{
  return [self getAdImage:AD_URL_768x90];
}

-(NSDictionary*)getMAdImage{
  return [self getAdImage:AD_URL_468x60];
}

-(NSDictionary*)getSAdImage{
  return [self getAdImage:AD_URL_320x50];
}

-(NSDictionary*)getAdImage:(NSString*)ad_url{
  
  NSError *err;
  NSData *data = [self downloadUrl:[NSURL URLWithString:[NSString stringWithFormat:ad_url, arc4random() ]] error:&err];
  XMLParser *parser = [[XMLParser alloc] init];
  return [parser getAdImageAndUrl:&data error:&err];
}

-(NSData *)downloadUrl:(NSURL*)url error:(NSError**)error{
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  
  [request setNumberOfTimesToRetryOnTimeout:1];
  [request setTimeOutSeconds:15];
  [request setCachePolicy:ASIDoNotWriteToCacheCachePolicy|ASIDoNotReadFromCacheCachePolicy];
  request.timeOutSeconds=15;
  [request setShouldAttemptPersistentConnection:NO];
  
  [request startSynchronous];
  
  NSError *request_error = [request error];
  if (request_error != nil) {
    if (error != nil) *error = request_error;
    return nil;
  }
  
  NSData *response = [request responseData];
  if (response == nil) {
    return [ErrorBuilder build:error desc:@"request null" code:ERR_REQUEST_NULL];
  }
  
  return response;
}
@end
