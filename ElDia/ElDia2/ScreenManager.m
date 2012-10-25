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

NSString * const MAIN_STYLESHEET     = @"1_main_list.xsl";
NSString * const NOTICIA_STYLESHEET  = @"3_new.xsl";
NSString * const SECTIONS_STYLESHEET = @"2_section_list.xsl";

NSString * const MAIN_URL     = @"http://www.eldia.com.ar/rss/index.aspx";
NSString * const NOTICIA_URL  = @"http://www.eldia.com.ar/rss/noticia.aspx?id=%@";
NSString * const SECTIONS_URL = @"http://www.eldia.com.ar/rss/index.aspx?seccion=%@";

@implementation ScreenManager

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


-(NSArray *)getSection:(NSString*)url useCache:(BOOL)useCache {
  return [self getScreen:url useCache:useCache prefix:@"s"];
}

-(NSArray *)getArticle:(NSString*)url useCache:(BOOL)useCache {
  return [self getScreen:url useCache:useCache prefix:@"a"];
}

-(NSArray *)getScreen:(NSString*)url useCache:(BOOL)useCache prefix:(NSString*)prefix{
  
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  NSData    *xml   = nil;
  
  //Si piden ver la cache
  if (useCache) {

    //Trato de traer el XML original
    xml = [cache get:key prefix:[prefix stringByAppendingString:@"x"]];

    //Si ya esta el html -> devuelvo (html, list<images>)
    //NOTA: se devuelven las imagenes y no se disparan las tareas de aca para que lo haga el que llamo, asi tiene tiempo de poner el contenido
    //      en el webview y no se pierden eventos de JS.
    
    NSData *html = [cache get:key prefix:prefix];

    if (html != nil) {
      NSArray *mobi_images = [self pendingImages:&xml];

      //Chequeamos si hay que borrar el xml
      [self remove_xml:key xml:xml mobi_images:mobi_images prefix:prefix];

      return [NSArray arrayWithObjects:html, mobi_images, nil];
    };

  }

  //Si no tengo xml (por que no esta o por que me forzaron a ir a la red)
  if (xml == nil) {
    
    //Lo bajo
    xml = [self downloadUrl:url];
    
    //Problemas downloading?
    if (xml == nil) {
      return nil;
    }
    
    //Cacheamos el xml
    [cache put:key data:xml prefix:[prefix stringByAppendingString:@"x"]];
  }
  
  //Rebuildeamos el xml
  NSArray *mobi_images = [self pendingImages:&xml];

  if (mobi_images == nil || xml == nil) {
    return nil; //TODO: por que fue?
  }
  
  //Generamos el html con el xml rebuildeado
  HTMLGenerator *htmlGen = [[HTMLGenerator alloc] init];
  NSData *html = [htmlGen generate:xml xslt_file:[self getStyleSheet:url]];
  
  //Lo storeamos
  [cache put:key data:html prefix:prefix];
  
  //Chequeamos si hay que borrar el xml
  [self remove_xml:key xml:xml mobi_images:mobi_images prefix:prefix];
  
  return [NSArray arrayWithObjects:html, mobi_images, nil];
}

-(void) remove_xml:(NSString*)key xml:(NSData *)xml mobi_images:(NSArray*)mobi_images prefix:(NSString*)prefix{
  //Borramos el xml de disco si existe y no hay mas imagenes por bajar
  if (xml != nil && mobi_images != nil && [mobi_images count] == 0 ) {
    DiskCache *cache = [DiskCache defaultCache];
    [cache remove:key prefix:[prefix stringByAppendingString:@"x"]];
  }
 
}

-(NSData *)downloadUrl:(NSString*)surl {
  
  NSURL *url = [self getXmlHttpUrl:surl];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request startSynchronous];
  
  NSError *error = [request error];
  if (error) {
    return nil; //download problem -> RETRY?
  }
  
  return [request responseData];
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

  return nil;
}

-(NSArray *)pendingImages:(NSData**)xml {
  XMLParser *parser = [[XMLParser alloc] init];
  NSArray *images = [parser extractImagesAndRebuild:xml];
  if (images == nil) {
    return nil;
  }
  
  NSMutableArray *ret = [[NSMutableArray alloc] init];
  
  DiskCache *cache = [DiskCache defaultCache];
  for (int i=0; i<[images count]; i++) {
    MobiImage *image = [images objectAtIndex:i];
    if( ![cache exists:image.local_uri prefix:@"i"] )
      [ret addObject:image];
  }
  
  return ret;
}

@end
