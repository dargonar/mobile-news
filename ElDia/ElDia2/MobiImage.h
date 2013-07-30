//
//  MobiImage.h
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobiImage : NSObject <NSCoding> {
  NSString *url;
  NSString *local_uri;
  NSString *noticia_id;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *local_uri;
@property (nonatomic, retain) NSString *noticia_id;
@property (nonatomic, retain) NSString *prefix;

+(MobiImage*)initWithData:(NSString*)_url _local_uri:(NSString*)_local_uri _noticia_id:(NSString*)_noticia_id _prefix:(NSString*)_prefix;
@end
