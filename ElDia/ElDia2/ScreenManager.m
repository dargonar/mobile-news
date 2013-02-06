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
#import "NewsManager.h"
#import "AppDelegate.h"

NSString * const MAIN_STYLESHEET          = @"1_main_list.xsl";
NSString * const NOTICIA_STYLESHEET       = @"3_new.xsl";
NSString * const SECTIONS_STYLESHEET      = @"2_section_list.xsl";
NSString * const MENU_STYLESHEET          = @"4_menu.xsl";
NSString * const CLASIFICADOS_STYLESHEET  = @"5_clasificados.xsl";

NSString * const iPad_MAIN_STYLESHEET                 = @"1_tablet_main_list.xsl";
NSString * const iPad_SECTION_STYLESHEET              = @"1_tablet_section_list.xsl";
NSString * const iPad_SECTION_NEWS_PT_STYLESHEET      = @"2_tablet_noticias_seccion_portrait.xsl";
NSString * const iPad_SECTION_NEWS_LS_STYLESHEET      = @"2_tablet_noticias_seccion_landscape.xsl";
NSString * const iPad_MAIN_NEWS_PT_STYLESHEET      = @"2_tablet_noticias_index_portrait.xsl";
NSString * const iPad_MAIN_NEWS_LS_STYLESHEET      = @"2_tablet_noticias_index_landscape.xsl";

NSString * const iPad_NOTICIA_PT_STYLESHEET           = @"3_tablet_new_portrait.xsl";
NSString * const iPad_NOTICIA_LS_STYLESHEET           = @"3_tablet_new_landscape.xsl";
NSString * const iPad_NOTICIAS_REL_PT_STYLESHEET      = @"3_tablet_new_relateds_portrait.xsl";
NSString * const iPad_NOTICIAS_REL_LS_STYLESHEET      = @"3_tablet_new_relateds_landscape.xsl";
NSString * const iPad_MENU_STYLESHEET                 = @"4_tablet_menu_secciones.xsl";
NSString * const iPad_CLASIFICADOS_STYLESHEET         = @".xsl";

NSString * const MAIN_URL             = @"http://www.eldia.com.ar/rss/index.aspx";
NSString * const NOTICIA_URL          = @"http://www.eldia.com.ar/rss/noticia.aspx?id=%@";
NSString * const SECTIONS_URL         = @"http://www.eldia.com.ar/rss/index.aspx?seccion=%@";
NSString * const MENU_URL             = @"http://www.eldia.com.ar/rss/secciones.aspx";
NSString * const CLASIFICADOS_URL     = @"http://www.eldia.com.ar/mc/clasi_rss.aspx?idr=%@&app=1";

@implementation ScreenManager

BOOL isIpad=NO;

-(id) init{
  self = [super init];
  if(self != nil){
    isIpad = [app_delegate isiPad];
  }
  return self;
}

-(NSDate*) sectionDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

/**/
-(BOOL) menuExists{
  return [self screenExists:@"menu://" prefix:@"m"];
}

-(BOOL) clasificadosExists:(NSString*)url {
  return [self screenExists:url prefix:@"c"];
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

  if(isIpad)
    if ([app_delegate isLandscape]) {
      prefix=[prefix stringByAppendingPathComponent:@"_l"];
    }
  return [cache exists:key prefix:prefix];
}

// para iPad
-(BOOL) sectionMenuExists:(NSString*)url {
  return [self screenExists:url prefix:@"sm"];
}

/***********************************************************************************/

-(NSData *)getMenu:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:@"menu://" useCache:useCache processImages:NO prefix:@"m" error:error];
}

-(NSData *)getClasificados:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"c" error:error];
}

-(NSData *)getSection:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"s" error:error processNavigation:YES url_prefix:nil];
}

// para iPAd
-(NSData *)getSectionMenu:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{

  //[NSString stringWithFormat:@"menu_%@", url]
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"sm" error:error processNavigation:NO url_prefix:@"menu_"];
}

-(NSData *)getArticle:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error {
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"a" error:error];
}

-(NSData *)getScreen:(NSString*)url useCache:(BOOL)useCache processImages:(BOOL)processImages prefix:(NSString*)prefix error:(NSError**)error {
  return [self getScreen:url useCache:useCache processImages:processImages prefix:prefix error:error processNavigation:NO url_prefix:nil];
}

-(NSData *)getScreen:(NSString*)url useCache:(BOOL)useCache processImages:(BOOL)processImages prefix:(NSString*)prefix error:(NSError**)error processNavigation:(BOOL)processNavigation url_prefix:(NSString*)urlPrefix {
  
  NSString* prefixedUrl = url;
  if(urlPrefix!=nil)
  {
   prefixedUrl = [NSString stringWithFormat:@"%@%@",urlPrefix, url];
  }
  
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:prefixedUrl];
  NSString  *xml_key   = [CryptoUtil sha1:url];
  
  //Si piden ver la cache
  if (useCache) {

    NSData *html = [cache get:key prefix:prefix];
    if (html != nil) {
      if(processNavigation)
      {
        [self processNewsForGestureNavigation:key];
      }
      
      return html;
    }

  }
  
  if(![Utils areWeConnectedToInternet])
  {
    return [ErrorBuilder build:error desc:@"no internet conection" code:ERR_NO_INTERNET_CONNECTION];
  }
  
  NSData *xml = nil;
  if (useCache && urlPrefix!=nil) {
    xml = [cache get:xml_key prefix:@"xml"];
  }
  
  //Lo bajo
  if(xml==nil)
    xml=[self downloadUrl:url error:error];
  
  //Problemas downloading?
  if (xml == nil) {	
    return nil;
  }
  
  if( ![url hasPrefix:@"clasificados://"] )
  {
    xml = [Utils sanitizeXML:xml unescaping_html_entities:([url hasPrefix:@"noticia://"]||[url hasPrefix:@"section://"])];
  }
  
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
  
  NSData *html = [htmlGen generate:xml xslt_file:[self getStyleSheet:prefixedUrl] error:error];
  
  if (html == nil) {
    return nil;
  }
  
  //Lo guardamos y retornamos
  if(![cache put:key data:html prefix:prefix]) {
    return [ErrorBuilder build:error desc:@"cache html" code:ERR_CACHING_HTML];
  }
  
  if([prefixedUrl hasPrefix:@"section://"])
    [cache put:key data:xml prefix:@"xml"];
  
  if(processNavigation)
  {
    [self processNewsForGestureNavigation:xml dummy:NO];
  }
  
  return html;
}

-(void)processNewsForGestureNavigation:(NSString*)key{
  DiskCache *cache = [DiskCache defaultCache];
  NSData *_xml=[cache get:key prefix:@"xml"];
  [self processNewsForGestureNavigation:_xml dummy:NO];
  
}

-(void)processNewsForGestureNavigation:(NSData*)xml dummy:(BOOL)dummy{
  
  XMLParser *parser = [[XMLParser alloc] init];
  NSError *error;
  NSArray* array = [parser extractNewsUrls:xml error:&error];
  [[NewsManager defaultNewsManager] setURLs:array];
  //  :(NSData**)xml_data error:(NSError **)error{
}


-(NSData *)downloadUrl:(NSString*)surl error:(NSError**)error {
  
  NSURL *url = [self getXmlHttpUrl:surl];
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


-(NSString*)getStyleSheet:(NSString*)url {
  
  if(isIpad)
  {
    return [self getStyleSheetiPad:url];
  }
  
  if( [url hasPrefix:@"section://main"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_STYLESHEET];
  }
  
  if( [url hasPrefix:@"noticia://" ] ) {  
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:NOTICIA_STYLESHEET];
  }
  
  
  if( [url hasPrefix:@"clasificados://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CLASIFICADOS_STYLESHEET];
  }
  
  if( [url hasPrefix:@"section://"] ) {  
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SECTIONS_STYLESHEET];
  }

  if( [url hasPrefix:@"menu://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MENU_STYLESHEET];
  }
  return nil;
}

-(NSString*)getStyleSheetiPad:(NSString*)url {
  
  if( [url hasPrefix:@"menu_section://main"] ) {
    NSString* sheet = app_delegate.isLandscape ? iPad_MAIN_NEWS_LS_STYLESHEET:iPad_MAIN_NEWS_PT_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"menu_section://"] ) {
    NSString* sheet = app_delegate.isLandscape ? iPad_SECTION_NEWS_LS_STYLESHEET:iPad_SECTION_NEWS_PT_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"section://main"] ) {
    NSString* sheet = iPad_MAIN_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"section://"] ) {
    NSString* sheet = iPad_SECTION_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
    
  }
  
  if( [url hasPrefix:@"noticia://" ] ) {
    NSString* sheet = app_delegate.isLandscape ? iPad_NOTICIA_LS_STYLESHEET:iPad_NOTICIA_PT_STYLESHEET;
    NSLog(@"ScreenManager::getStyleSheetiPad:: noticia:[%@]", sheet);
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  
  if( [url hasPrefix:@"clasificados://"] ) {
    NSString* sheet = iPad_CLASIFICADOS_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"section_menu://"] ) {
    NSString* sheet = app_delegate.isLandscape ? iPad_SECTION_NEWS_LS_STYLESHEET:iPad_SECTION_NEWS_PT_STYLESHEET;
    NSLog(@"ScreenManager::getStyleSheetiPad:: section_menu:[%@]", sheet);
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
    
  }
  
  if( [url hasPrefix:@"menu://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:iPad_MENU_STYLESHEET];
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

  if( [url hasPrefix:@"clasificados://"] ) {
    NSURL *tmp = [NSURL URLWithString:url];
    return [NSURL URLWithString:[NSString stringWithFormat:CLASIFICADOS_URL,[tmp host]]];
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
