//
//  ScreenManager.m
//  ElDia
//
//  Created by Matias on 10/24/12.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "ScreenManager.h"
#import "DiskCache.h"
#import "CryptoUtil.h"
#import "HTMLGenerator.h"
#import "ASIHTTPRequest.h"
#import "XMLParser.h"
#import "MobiImage.h"
#import "ErrorBuilder.h"
#import "Utils.h"

NSString * const MAIN_STYLESHEET      = @"1_main_list.xsl";
NSString * const NOTICIA_STYLESHEET   = @"3_new.xsl";
NSString * const SECTIONS_STYLESHEET  = @"2_section_list.xsl";
NSString * const MENU_STYLESHEET      = @"4_menu.xsl";

NSString * const MAIN_URL     = @"http://www.eldia.com.ar/rss/index.aspx";
NSString * const NOTICIA_URL  = @"http://www.eldia.com.ar/rss/noticia.aspx?id=%@";
NSString * const SECTIONS_URL = @"http://www.eldia.com.ar/rss/index.aspx?seccion=%@";
NSString * const MENU_URL     = @"http://www.eldia.com.ar/rss/secciones.aspx";

@implementation ScreenManager

-(NSDate*) sectionDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

/**/
-(BOOL) menuExists{
  return [self screenExists:@"menu://" prefix:@"m"];
}

-(BOOL) sectionExists:(NSString*)url {
  return [self screenExists:url prefix:@"s"];
}

-(BOOL) articleExists:(NSString*)url {
  return [self screenExists:url prefix:@"a"];
}

-(BOOL) screenExists:(NSString*)url prefix:(NSString*)prefix {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];

  return [cache exists:key prefix:prefix];
}

/***********************************************************************************/

-(NSData *)getMenu:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:@"menu://" useCache:useCache processImages:NO prefix:@"m" error:error];
}

-(NSData *)getSection:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"s" error:error];
}

-(NSData *)getArticle:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error {
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"a" error:error];
}

-(NSData *)getScreen:(NSString*)url useCache:(BOOL)useCache processImages:(BOOL)processImages prefix:(NSString*)prefix error:(NSError**)error {
  
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  
  //Si piden ver la cache
  if (useCache) {

    NSData *html = [cache get:key prefix:prefix];
    if (html != nil) {
      return html;
    }

  }
  
  //Lo bajo
  NSData *xml = [self downloadUrl:url error:error];
  
  //Problemas downloading?
  if (xml == nil) {
    return nil;
  }
  
  xml = [Utils sanitizeXML:xml];
  
  if(processImages)
  {
    //Rebuildeamos el xml
    XMLParser *parser = [[XMLParser alloc] init];
    NSArray *mobi_images = [parser extractImagesAndRebuild:&xml error:error];
    if (mobi_images == nil) {
      return nil;
    }
    
    //Serializamos las imagenes a un NSData
    NSData *tmp = [NSKeyedArchiver archivedDataWithRootObject:mobi_images];
    if (tmp == nil) {
      return [ErrorBuilder build:error desc:@"archive mobiimages" code:ERR_SERIALIZING_MI];
    }
    
    //Las guardamos en cache
    if(![cache put:key data:tmp prefix:@"mi"]) {
      return [ErrorBuilder build:error desc:@"cache mobimages" code:ERR_CACHING_MI];
    }
  }
  
  //Generamos el html con el xml rebuildeado
  HTMLGenerator *htmlGen = [[HTMLGenerator alloc] init];
  
  NSData *html = [htmlGen generate:xml xslt_file:[self getStyleSheet:url] error:error];
  
  if (html == nil) {
    return nil;
  }
  
  //Lo guardamos y retornamos
  if(![cache put:key data:html prefix:prefix]) {
    return [ErrorBuilder build:error desc:@"cache html" code:ERR_CACHING_HTML];
  }
    
  return html;
}

-(NSData *)downloadUrl:(NSString*)surl error:(NSError**)error {
  
  NSURL *url = [self getXmlHttpUrl:surl];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
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


-(NSString*)getStyleSheet:(NSString*)url {

  if( [url hasPrefix:@"section://main"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_STYLESHEET];
  }
  
  if( [url hasPrefix:@"noticia://" ] ) {  
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:NOTICIA_STYLESHEET];
  }
  
  if( [url hasPrefix:@"section://"] ) {  
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SECTIONS_STYLESHEET];
  }

  if( [url hasPrefix:@"menu://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MENU_STYLESHEET];
  }
  return nil;
}

-(NSURL*) getXmlHttpUrl:(NSString*)url {
  
  if( [url hasPrefix:@"section://main"] ) {
    return [NSURL URLWithString:MAIN_URL];
  }
  
  if( [url hasPrefix:@"noticia://" ] ) {  
    NSURL *tmp = [NSURL URLWithString:url];
    return [NSURL URLWithString:[NSString stringWithFormat:NOTICIA_URL,[tmp host]]];
  }
  
  if( [url hasPrefix:@"section://"] ) {
    NSURL *tmp = [NSURL URLWithString:url];
    return [NSURL URLWithString:[NSString stringWithFormat:SECTIONS_URL,[tmp host]]];
  }

  if( [url hasPrefix:@"menu://"] ) {
    return [NSURL URLWithString:MENU_URL];
  }
  

  return nil;
}

-(NSArray *)getPendingImages:(NSString*)url error:(NSError**)error {
  
  NSString *key = [CryptoUtil sha1:url];
  NSArray *images = [self getImages:key error:error];
  if (images == nil) {
    return nil;
  }

  DiskCache      *cache = [DiskCache defaultCache];
  NSMutableArray *ret = [[NSMutableArray alloc] init];
  
  for (int i=0; i<[images count]; i++) {
    MobiImage *image = [images objectAtIndex:i];
    if( ![cache exists:image.local_uri prefix:@"i"] )
      [ret addObject:image];
  }

  //Vacio? ya estan todas bajadas borramos "mi"
  if ([ret count] == 0 ) {
    [cache remove:key prefix:@"mi"];
  }
  
  return ret;
}

-(NSArray *)getImages:(NSString*)key error:(NSError**)error {

  DiskCache      *cache = [DiskCache defaultCache];
  NSData *data = [cache get:key prefix:@"mi"];

  if(data == nil) {
    return nil;
  }
  
  NSArray *mobi_images = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  if (mobi_images == nil) {
    return [ErrorBuilder build:error desc:@"unarchive failed" code:ERR_DESERIALIZING_MI];
  }

  return mobi_images;
}

@end
