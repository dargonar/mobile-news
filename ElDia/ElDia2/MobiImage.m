//
//  MobiImage.m
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "MobiImage.h"

@implementation MobiImage
@synthesize url, local_uri, noticia_id;

- (id)init {
  
  if ((self = [super init])) {
  }
  return self;
  
}

- (id)initWithCoder:(NSCoder *)decoder {
  NSString *tmp_url        = [decoder decodeObject];
  NSString *tmp_localuri   = [decoder decodeObject];
  NSString *tmp_noticia_id = [decoder decodeObject];
  return [MobiImage initWithData:tmp_url _local_uri:tmp_localuri _noticia_id:tmp_noticia_id];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.url];
  [encoder encodeObject:self.local_uri];
  [encoder encodeObject:self.noticia_id];
}

+(MobiImage*)initWithData:(NSString*)_url _local_uri:(NSString*)_local_uri _noticia_id:(NSString*)_noticia_id{
  MobiImage* _MobiImage=[[MobiImage alloc] init];
  [_MobiImage setLocal_uri:_local_uri];
  [_MobiImage setNoticia_id:_noticia_id];
  [_MobiImage setUrl:_url];
  return _MobiImage;
}


- (void) dealloc {
  self.url = nil;
  self.local_uri=nil;
  self.noticia_id=nil;
  //[super dealloc];
}

@end