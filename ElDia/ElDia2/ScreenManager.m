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
NSString * const FUNEBRES_STYLESHEET      = @"6_funebres.xsl";
NSString * const FARMACIAS_STYLESHEET     = @"7_farmacias.xsl";
NSString * const CARTELERA_STYLESHEET      = @"8_cartelera.xsl";

NSString * const iPad_MAIN_STYLESHEET                 = @"1_tablet_main_list.xsl";
NSString * const iPad_SECTION_STYLESHEET              = @"1_tablet_section_list.xsl";
NSString * const iPad_SECTION_NEWS_PT_STYLESHEET      = @"2_tablet_noticias_seccion_portrait.xsl";
NSString * const iPad_SECTION_NEWS_LS_STYLESHEET      = @"2_tablet_noticias_seccion_landscape.xsl";
NSString * const iPad_MAIN_NEWS_PT_STYLESHEET      = @"2_tablet_noticias_index_portrait.xsl";
NSString * const iPad_MAIN_NEWS_LS_STYLESHEET      = @"2_tablet_noticias_index_landscape.xsl";

//NSString * const iPad_NOTICIA_PT_STYLESHEET           = @"3_tablet_new_portrait.xsl";
NSString * const iPad_NOTICIA_PT_STYLESHEET           = @"3_tablet_new_global.xsl";
NSString * const iPad_NOTICIA_LS_STYLESHEET           = @"3_tablet_new_landscape.xsl";
NSString * const iPad_NOTICIAS_REL_PT_STYLESHEET      = @"3_tablet_new_relateds_portrait.xsl";
NSString * const iPad_NOTICIAS_REL_LS_STYLESHEET      = @"3_tablet_new_relateds_landscape.xsl";
NSString * const iPad_MENU_STYLESHEET                 = @"4_tablet_menu_secciones.xsl";
NSString * const iPad_CLASIFICADOS_STYLESHEET         = @"5_tablet_clasificados.xsl";
NSString * const iPad_FUNEBRES_STYLESHEET             = @"6_tablet_funebres.xsl";
NSString * const iPad_FARMACIAS_STYLESHEET            = @"7_tablet_farmacias.xsl";
NSString * const iPad_CARTELERA_STYLESHEET            = @"8_tablet_cartelera.xsl";

NSString * const MAIN_URL             = @"http://www.eldia.com.ar/rss/index.aspx";
NSString * const NOTICIA_URL          = @"http://www.eldia.com.ar/rss/noticia.aspx?id=%@";
NSString * const SECTIONS_URL         = @"http://www.eldia.com.ar/rss/index.aspx?seccion=%@";
NSString * const MENU_URL             = @"http://www.eldia.com.ar/rss/secciones.aspx";
//NSString * const CLASIFICADOS_URL     = @"http://www.eldia.com.ar/mc/clasi_rss.aspx?idr=%@&app=1";
NSString * const CLASIFICADOS_URL     = @"http://www.eldia.com.ar/mc/clasi_rss_utf8.aspx?idr=%@&app=1";
NSString * const FUNEBRES_URL         = @"http://www.eldia.com.ar/mc/fune_rss_utf8.aspx";

NSString * const CARTELERA_URL     = @"http://www.eldia.com.ar/extras/carteleradecine_txt.aspx";
NSString * const FARMACIAS_URL     = @"http://www.eldia.com.ar/extras/farmacias_txt.aspx";

@implementation ScreenManager

BOOL isIpad=NO;

-(id) init{
  self = [super init];
  if(self != nil){
    isIpad = [app_delegate isiPad];
  }
  return self;
}


+(BOOL)isMainScreenPrefix:(NSString*)prefix{
  if([prefix isEqualToString:@"a"] || [prefix isEqualToString:@"a"])
    return YES;
  return NO;
}

-(NSDate*) sectionDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

-(NSDate*) funebresDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"f"];
}


-(NSDate*) clasificadosDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"c"];
}

-(NSDate*) farmaciaDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"farm"];
}

-(NSDate*) carteleraDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"car"];
}

/**/
-(BOOL) menuExists{
  return [self screenExists:@"menu://" prefix:@"m"];
}

-(BOOL) clasificadosExists:(NSString*)url {
  return [self screenExists:url prefix:@"c"];
}

-(BOOL) funebresExists:(NSString*)url {
  return [self screenExists:url prefix:@"f"];
}

-(BOOL) farmaciaExists:(NSString*)url {
  return [self screenExists:url prefix:@"far"];
}

-(BOOL) carteleraExists:(NSString*)url {
  return [self screenExists:url prefix:@"car"];
}

-(BOOL) sectionExists:(NSString*)url {
  //NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"_ls_"):(@"");
  //NSString *composedPrefix = [NSString stringWithFormat:@"%@%@",@"s", html_prefix];
  //return [self screenExists:url prefix:composedPrefix];
  return [self screenExists:url prefix:@"s"];
}

-(BOOL) articleExists:(NSString*)url {
  //NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"_ls_"):(@"");
  //NSString *composedPrefix = [NSString stringWithFormat:@"%@%@",@"a", html_prefix];
  //return [self screenExists:url prefix:composedPrefix];
  return [self screenExists:url prefix:@"a"];
}

-(BOOL) screenExists:(NSString*)url prefix:(NSString*)prefix {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];

  return [cache exists:key prefix:prefix];
}

// para iPad
-(BOOL) sectionMenuExists:(NSString*)url {
  NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_menu_"):(@"menu_");
  NSString *composedPrefix = [NSString stringWithFormat:@"%@_%@",@"sm", html_prefix];
  return [self screenExists:url prefix:composedPrefix];
}

/***********************************************************************************/

-(NSData *)getMenu:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:@"menu://" useCache:useCache processImages:NO prefix:@"m" error:error];
}

-(NSData *)getClasificados:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"c" error:error];
}

-(NSData *)getFunebres:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"f" error:error];
}

-(NSData *)getFarmacia:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"far" error:error];
}

-(NSData *)getCartelera:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"car" error:error];
}

-(NSData *)getSection:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  
  //NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_"):nil;
  //return [self getScreen:url useCache:useCache processImages:YES prefix:@"s" error:error processNavigation:YES html_prefix:html_prefix];
  
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"s" error:error processNavigation:YES html_prefix:nil];
}

// para iPAd
-(NSData *)getSectionMenu:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  
  NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_menu_"):(@"menu_");
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"sm" error:error processNavigation:NO html_prefix:html_prefix];
}

-(NSData *)getArticle:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error {
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"a" error:error];
  
  //NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_"):(nil);
  //return [self getScreen:url useCache:useCache processImages:YES prefix:@"a" error:error processNavigation:NO html_prefix:html_prefix];
}


-(NSData *)getScreen:(NSString*)url useCache:(BOOL)useCache processImages:(BOOL)processImages prefix:(NSString*)prefix error:(NSError**)error {
  return [self getScreen:url useCache:useCache processImages:processImages prefix:prefix error:error processNavigation:NO html_prefix:nil];
}

-(NSData *)getScreen:(NSString*)url useCache:(BOOL)useCache processImages:(BOOL)processImages prefix:(NSString*)prefix error:(NSError**)error processNavigation:(BOOL)processNavigation html_prefix:(NSString*)html_prefix {
  
  // urlPrefix es para utilizar el mismo xml que 'url', pero generar otro HTML.
  
  NSString* prefixedUrl = url;
  NSString* composedHtmlPrefix = prefix;
  if(html_prefix!=nil)
  {
    prefixedUrl = [NSString stringWithFormat:@"%@%@",html_prefix, url];
    composedHtmlPrefix = [NSString stringWithFormat:@"%@_%@",prefix, html_prefix];
  }
  
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  //NSString  *xml_key   = [CryptoUtil sha1:url];
  
  NSLog(@" url[%@]; prefix:[%@].", url, composedHtmlPrefix);
  
  //Si piden ver la cache
  if (useCache) {

    NSData *html = [cache get:key prefix:composedHtmlPrefix];
    if (html != nil) {
      if(processNavigation)
      {
        [self processNewsForGestureNavigation:key];
        //[self processNewsForGestureNavigation:xml_key];
      }
      
      return html;
    }

  }
  
  if(![Utils areWeConnectedToInternet])
  {
    return [ErrorBuilder build:error desc:@"no internet conection" code:ERR_NO_INTERNET_CONNECTION];
  }
  
  NSData *xml = nil;
  // Esto significa que me piden de cache pero el html no esta cacheado, pero si lo esta el xml.
  if (useCache && html_prefix!=nil) {
    xml = [cache get:key prefix:@"xml"];
  }
  
  //Lo bajo
  BOOL downloaded = (xml==nil);
  if(downloaded)
    xml=[self downloadUrl:url error:error hack_xml:([url hasPrefix:@"farmacia://"] || [url hasPrefix:@"cartelera://"])];
  
  //Problemas downloading?
  if (xml == nil) {	
    return nil;
  }
  
  //No sanitizamos clasificados porque viene en formato !UTF8.
  //if( ![url hasPrefix:@"clasificados://"] && downloaded==YES)
  if( downloaded==YES)
  {
    xml = [Utils sanitizeXML:xml unescaping_html_entities:([url hasPrefix:@"noticia://"] || [url hasPrefix:@"section://"] || [url hasPrefix:@"clasificados://"])];
  }
  
  if(processImages && downloaded==YES)
  {
    //Rebuildeamos el xml
    XMLParser *parser = [[XMLParser alloc] init];
    NSArray *mobi_images = [parser extractImagesAndRebuild:&xml error:error prefix:prefix];
    /*
     // Por que voy a retornar? si no tiene imagenes, no tiene imagenes!
    if (mobi_images == nil) {
      return nil;
    }
     */
    if (mobi_images != nil) {
      
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
  }
    
  //Generamos el html con el xml rebuildeado
  HTMLGenerator *htmlGen = [[HTMLGenerator alloc] init];
  
  NSData *html = [htmlGen generate:xml xslt_file:[self getStyleSheet:prefixedUrl] error:error];
  
  if (html == nil) {
    return nil;
  }
  
  //Lo guardamos y retornamos
  if(![cache put:key data:html prefix:composedHtmlPrefix]) {
    return [ErrorBuilder build:error desc:@"cache html" code:ERR_CACHING_HTML];
  }
  
  if(([url hasPrefix:@"section://"] || [url hasPrefix:@"noticia://"]) && downloaded)
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


-(NSData *)downloadUrl:(NSString*)surl error:(NSError**)error hack_xml:(BOOL)hack_xml {
  
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
 
  if(hack_xml==YES)
  {
    NSString *xml = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];
    NSString *date = [dateFormatter stringFromDate:[[NSDate alloc] init]];
   // NSLog(@"DateObject : %@", date);
    
    NSString *hacked_xml = @"<rss xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:news=\"http://www.diariosmoviles.com.ar/news-rss/\" version=\"2.0\"><channel><pubDate>%@ -0300</pubDate><item><![CDATA[%@]]></item></channel></rss>";
    
    NSLog(@" hacked xml surl[%@] data[%@]", surl, xml);
    
    response = [[NSString stringWithFormat:hacked_xml,date, xml] dataUsingEncoding:NSUTF8StringEncoding];
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
  
  if( [url hasPrefix:@"funebres://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:FUNEBRES_STYLESHEET];
  }
  
  if( [url hasPrefix:@"section://"] ) {  
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SECTIONS_STYLESHEET];
  }

  if( [url hasPrefix:@"menu://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MENU_STYLESHEET];
  }
  
  if( [url hasPrefix:@"farmacia://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:FARMACIAS_STYLESHEET];
  }

  if( [url hasPrefix:@"cartelera://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CARTELERA_STYLESHEET];
  }

  return nil;
}

-(NSString*)getStyleSheetiPad:(NSString*)url {
  
  if( [url hasPrefix:@"menu_section://main"] ) {
    NSString* sheet = iPad_MAIN_NEWS_PT_STYLESHEET; //app_delegate.isLandscape ? iPad_MAIN_NEWS_LS_STYLESHEET:iPad_MAIN_NEWS_PT_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"section_menu://"] ) {
    NSString* sheet = app_delegate.isLandscape ? iPad_SECTION_NEWS_LS_STYLESHEET:iPad_SECTION_NEWS_PT_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
    
  }
  
  if( [url hasPrefix:@"ls_menu_section://main"] ) {
    NSString* sheet = iPad_MAIN_NEWS_LS_STYLESHEET; //app_delegate.isLandscape ? iPad_MAIN_NEWS_LS_STYLESHEET:iPad_MAIN_NEWS_PT_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"ls_menu_section://"] ) {
    NSString* sheet = iPad_SECTION_NEWS_LS_STYLESHEET; 
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
  
  if( [url hasPrefix:@"ls_section://"] ) {
    NSString* sheet = SECTIONS_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
    
  }
  
  if( [url hasPrefix:@"noticia://" ] ) {
    NSString* sheet = iPad_NOTICIA_PT_STYLESHEET; //app_delegate.isLandscape ? iPad_NOTICIA_LS_STYLESHEET:iPad_NOTICIA_PT_STYLESHEET;
    NSLog(@"ScreenManager::getStyleSheetiPad:: noticia:[%@]", sheet);
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"ls_noticia://" ] ) {
    NSString* sheet = iPad_NOTICIA_LS_STYLESHEET; 
    NSLog(@"ScreenManager::getStyleSheetiPad:: noticia:[%@]", sheet);
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  
  if( [url hasPrefix:@"clasificados://"] ) {
    NSString* sheet = iPad_CLASIFICADOS_STYLESHEET;
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sheet];
  }
  
  if( [url hasPrefix:@"funebres://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:iPad_FUNEBRES_STYLESHEET];
  }
    
  if( [url hasPrefix:@"menu://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:iPad_MENU_STYLESHEET];
  }
  
  if( [url hasPrefix:@"farmacia://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:iPad_FARMACIAS_STYLESHEET];
  }
  
  if( [url hasPrefix:@"cartelera://"] ) {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:iPad_CARTELERA_STYLESHEET];
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
  
  if( [url hasPrefix:@"funebres://"] ) {
    return [NSURL URLWithString:FUNEBRES_URL];
  }

  if( [url hasPrefix:@"farmacia://"] ) {
    return [NSURL URLWithString:FARMACIAS_URL];
  }

  if( [url hasPrefix:@"cartelera://"] ) {
    return [NSURL URLWithString:CARTELERA_URL];
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
