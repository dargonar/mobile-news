//
//  NewsManager.m
//  ElDia
//
//  Created by Lion User on 29/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "NewsManager.h"

@implementation NewsManager

NSMutableArray *_ids_de_noticias=nil;
NSMutableArray *_urls_de_noticias=nil;

+ (NewsManager *) defaultNewsManager
{
  static NewsManager *defaultNewsManager = NULL;
  @synchronized(self)
  {
    if(defaultNewsManager == NULL)
      defaultNewsManager = [[NewsManager alloc] init];
  }
  
  return defaultNewsManager;
}

-(void)setURLs:(NSArray*)array
{
  _ids_de_noticias=nil;
  _urls_de_noticias=nil;
  _urls_de_noticias=[array copy];
  for(int i =0; i<[array count]; i++)
    [_ids_de_noticias addObject:[(NSURL*)[array objectAtIndex:i] host]];
}

-(NSURL*)getNextNoticiaId:(NSString*)_noticia_id
{
  if(_ids_de_noticias==nil)
  {
    return nil;
  }
  //_noticia_id = [_noticia_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
  NSUInteger index = [_ids_de_noticias indexOfObject:_noticia_id];
  if(index==NSNotFound)
    return nil;
  if ((index+1)<[_ids_de_noticias count]) {
    return [_urls_de_noticias objectAtIndex:(index+1)];
  }
  return nil;
}

-(NSURL*)getPrevNoticiaId:(NSString*)_noticia_id
{
  
  if(_ids_de_noticias==nil)
  {
    return nil;
  }
  //_noticia_id = [_noticia_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
  NSUInteger index = [_ids_de_noticias indexOfObject:_noticia_id];
  if(index==NSNotFound)
    return nil;
  if (index>0) {
    return [_urls_de_noticias objectAtIndex:(index-1)];
  }
  return nil;
}

@end
