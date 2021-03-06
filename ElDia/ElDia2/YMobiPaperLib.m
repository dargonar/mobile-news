//
//  YMobiPaperLib.m
//  ElDia2
//
//  Created by Lion User on 28/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "YMobiPaperLib.h"
#import "RegexKitLite.h"
#import "asi-http-request/ASIHTTPRequest.h"
#import "XMLParser.h"

#define KEY_XSL @"key_xsl"
#define KEY_VIEW @"key_view"
#define KEY_TAG @"key_tag"
#define KEY_DATA @"key_data"

@implementation YMobiPaperLib

@synthesize urls, messages, requestsMetadata, delegate, metadata;

NSLock *errorLock;
NSLock *sqliteLock;
NSError *lastError;

static NSMutableArray *_ids_de_noticias=nil;
- (id)init{
	
	if (self = [super init]) {
    urls = [[NSArray alloc] initWithObjects:
            @"http://www.eldia.com.ar/rss/index.aspx",
            @"http://www.eldia.com.ar/rss/noticia.aspx?id=%@",
            @"http://www.eldia.com.ar/rss/secciones.aspx",
            @"http://www.eldia.com.ar/rss/index.aspx?seccion=%@",
            /*@"http://www.andigital.com.ar/dm_rss_mainstream.php",
            @"http://www.andigital.com.ar/dm_rss_mainstream.php?noticia_id=%@",
            @"http://www.andigital.com.ar/dm_rss_mainstream.php?secciones=%@",
            @"http://www.andigital.com.ar/dm_rss_mainstream.php?seccion_id=%@",*/
            nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:
                     MSG_GET_MAIN,
                     MSG_GET_NEW,
                     MSG_GET_SECTION_LIST,
                     MSG_GET_SECTIONS,
                     MSG_UPD_MAIN,
                     MSG_UPD_SECTION_LIST,
                     nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:
                       @"Acabamos de actualizar el listado de noticias!",
                       @"Aqui esta la noticia!",
                       @"Acabamos de actualizar el listado de noticias de la seccion!",
                       @"",
                       @"Acabamos de actualizar el listado de noticias!",
                       @"Acabamos de actualizar el listado de noticias de la seccion!",
                       nil];
    messages = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
    requestsMetadata = [[NSMutableDictionary alloc] init];
    sqliteLock = [[NSLock alloc] init];
    errorLock = [[NSLock alloc] init];
    keys=nil;
    values=nil;
  }
	return self;
}

/*
 [myLock lock]; locks the lock. This prevents other threads that are trying to acquire the lock from continuing until the lock is released.
 [myLock unlock]; unlocks the lock. This can only be done by the thread that locked the lock, and obviously allows other threads to acquire it.
 [myLock tryLock]; attempts to lock the lock, returns NO if it fails, otherwise returns YES.
 [myLock lockBeforeDate:]; attemp
 */

-(void)setLasError:(NSError*)error{
  if([errorLock tryLock])
  {
    lastError = [error copy];
    [errorLock unlock];
  }
}

-(void)setLasErrorDesc:(NSString*)error{
  NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
  [errorDetail setValue:error forKey:NSLocalizedDescriptionKey];
  [self setLasError:[NSError errorWithDomain:@"eldia.com.ar" code:0 userInfo:errorDetail]] ;
  errorDetail=nil;
}

-(NSError*)getLasError{
  if([errorLock tryLock])
  {
    NSError* local_copy = [lastError copy];
    lastError=nil;
    [errorLock unlock];
    return local_copy;
  }
  return nil;
}

-(NSString *)loadURL:(NSString *)path{
  
  NSURL *url = [NSURL URLWithString:path];
  
  //[ASIHTTPRequest setDefaultTimeOutSeconds:15];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setNumberOfTimesToRetryOnTimeout:1];
  [request setTimeOutSeconds:15];
  [request setCachePolicy:ASIDoNotWriteToCacheCachePolicy|ASIDoNotReadFromCacheCachePolicy];
  request.timeOutSeconds=15;
  [request setShouldAttemptPersistentConnection:NO];
  
  [request startSynchronous];
  
  NSError *error = [request error];
  if (!error) {
    if ([request responseStatusCode]!=200)
    {
      [self setLasErrorDesc:@"Servidor Inaccesible"];
      return nil;
    }
    return [request responseString];
  }
  [self setLasError:error];
  return nil;
  //return [NSString stringWithContentsOfURL:[NSURL URLWithString:path] encoding:NSUTF8StringEncoding error:nil];
}

-(NSString *)buildHtml:(NSString *)xml xsl:(NSString *)xsl{
  
  NSString *cleanedXML = @"";
  NSString* path_xslt = [[NSBundle mainBundle] pathForResource:xsl  ofType:@"xsl"];
  
  NSString *htmlAttributesRegex = @"(?<=<)([^/>]+)(\\s(style|class)=['\"][^'\"]+?['\"])([^/>]*)(?=/?>|\\s)";
  //  source: http://www.andrewbarber.com/post/Remove-HTML-Attributes-and-Tags-from-HTML-Source.aspx
  //  (?<=<):                                 (-) starting '<', no matchea ningun grupo.
  //  ([^/>]+):                               (1) matchea todo lo que haya entre '<' y 'style="...'. Por ejemplot 'span font="12px;"  '.
  //  (\\s(style|class)=['\"][^'\"]+?['\"]):  (2) matchea 'style="<estilo>"', atributo entre comillas simples o dobles.
  //  ([^/>]*):                               (3) asegura que termina en espacio(' ') o en cierre de tag '>';
  //  (?=/?>|\\s):                            (-) aseguramos que se trata de un tag y metemos en el tercer cualquier otro atributo del tag.
  
  NSString *undecodedAmpersandRegex = @"&(?![a-zA-Z0-9#]+;)" ; //@"/&(?![a-z#]+;)/i";
  
  HTMLGenerator *generator = [[HTMLGenerator alloc] init];
  
  @try{
    // Limpiamos el XML quitandole los stributos class y style de las etiquetas.
    cleanedXML = [xml stringByReplacingOccurrencesOfRegex:htmlAttributesRegex withString:@"$1"];
    
    //Limpiamos otras mierdas
    //cleanedXML = [cleanedXML stringByReplacingOccurrencesOfString:@" & " withString:@" &amp;"];
    cleanedXML = [xml stringByReplacingOccurrencesOfRegex:undecodedAmpersandRegex withString:@"&amp;"];
    
    NSLog(@" cleanedXML:%@", xsl);
    //return [generator generate:cleanedXML xslt_file:path_xslt error:error)];
  }
  @catch (NSException * e) {
    NSLog(@"YMobiPaperLib::buildHtml e:%@", e.reason);
    [self requestFailed:nil message:e.reason];
  }
  @finally {
    cleanedXML=nil;
    path_xslt=nil;
    htmlAttributesRegex=nil;
    generator=nil;
    
  }
}


-(NSString *)getUrl:(YMobiNavigationType)item queryString:(NSString *)queryString{
  NSString *path = [urls objectAtIndex:(NSInteger)item];
  if ([queryString length]>0) {
    path = [[NSString alloc] initWithFormat:path,queryString];
  }
  return path;
}

-(NSString*)getHtmlPath:(NSString*)path{
  return [NSString stringWithFormat:@"%@.html",path];
};

// publica
-(NSData*)getHtml:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl  {
 return [self getHtml:[self getUrl:item queryString:queryString] xsl:xsl];
}
// publica
-(NSData*)getHtml:(NSString *)path xsl:(NSString *)xsl {
  
  NSData   *data     = nil;
  NSString *mimeType = nil;
  NSString *html_path = [self getHtmlPath:path];
  
  /*
  NSArray  *cache = nil;
  while (![sqliteLock tryLock]) {
    //
  }
  cache=[[SqliteCache defaultCache] get:html_path];
  [sqliteLock unlock];
  if(cache) {
    // Si esta en cache la devolvemos!
    //ToDo: chquear que sea noticia o main, y cargar los componenetes necesarios.
    data     = [cache objectAtIndex:0];
    mimeType = [cache objectAtIndex:1];
  }
  else
  {
    // No esta en cache, la buscamos sync
    NSString *xml = [self loadURL:path];
    
    if(xml==nil){
      return nil;
    }
    
    NSString *html = [self buildHtml:xml xsl:xsl];
    if(html==nil)
    {
      [self setLasErrorDesc:@"XML Invalido"];
      return nil;
    }
    data     = [NSData dataWithBytes:[html UTF8String] length:[html length]+1];
    
    while (![sqliteLock tryLock]) {
      
      //
    }
    [[SqliteCache defaultCache] set:html_path data:data mimetype:@"text/html"];
    [sqliteLock unlock];
    
  
    // Solo cacheamos el XML.
    NSData *data_xml    = [xml dataUsingEncoding:NSUTF8StringEncoding] ;// [NSData dataWithBytes:[xml UTF8String] length:[xml length]+1];
    while (![sqliteLock tryLock]) {
      //
    }
    [[SqliteCache defaultCache] set:path data:data_xml mimetype:@"text/xml"];
    [sqliteLock unlock];
    
    xml = nil;
    html=nil;
    data_xml=nil;
  }
   */
  
  NSString *xml = [self loadURL:path];
  
  if(xml==nil){
    return nil;
  }
  
  NSString *html = [self buildHtml:xml xsl:xsl];
  if(html==nil)
  {
    [self setLasErrorDesc:@"XML Invalido"];
    return nil;
  }
  
  data = [NSData dataWithBytes:[html UTF8String] length:[html length]+1];
  
  NSData *data_xml    = [xml dataUsingEncoding:NSUTF8StringEncoding] ;
  // [NSData dataWithBytes:[xml UTF8String] length:[xml length]+1];
  
  
  xml = nil;
  html=nil;
  data_xml=nil;
  
  mimeType = nil;
  html_path = nil;
  //cache = nil;
  return data;

}

-(bool)mustReloadPath:(YMobiNavigationType)item queryString:(NSString *)queryString{
  
  if(item!=YMobiNavigationTypeMain && item!=YMobiNavigationTypeSectionNews && item!=YMobiNavigationTypeSections)
    return NO;
  NSString* path = [self getUrl:item queryString:queryString];
  NSArray  *cache = nil;
    
  path=nil;
  if(cache) {
    cache=nil;
    return NO;
  }
  cache=nil;
  return YES;
}

- (void)cleanCache{
      
  
}

-(NSData*) getChachedDataAndConfigure:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag fire_event:(BOOL)fire_event{
  NSString* path=[self getUrl:item queryString:queryString];
  NSString *html_path = [self getHtmlPath:path];
  NSData   *data     = [self getChachedData:html_path tag:tag fire_event:fire_event];
  if(data==nil)
  {
    path=nil;
    html_path=nil;
    
    return nil;
  }
  
  NSData* xml_data = [self getChachedData:path tag:tag fire_event:NO];
  if(xml_data==nil)
  {
    data=nil;
    path=nil;
    html_path=nil;
  
    return nil;
  }
  [self configureXSL:xsl xml:[[NSString alloc] initWithData:xml_data encoding:NSUTF8StringEncoding]];
  path=nil;
  html_path=nil;
  xml_data=nil;

  return data;
}

-(NSData*) getChachedData:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag fire_event:(BOOL)fire_event is_html:(BOOL)is_html{
  NSString* path = [self getUrl:item queryString:queryString];
  if (is_html==YES) {
    path = [self getHtmlPath:path];
  }
  return [self getChachedData:path tag:tag fire_event:fire_event];
}

-(NSData*) getChachedData:(NSString*)path tag:(NSString*)tag fire_event:(BOOL)fire_event{
  
  NSArray  *cache = nil;
  if(cache)
  {
    NSData   *data     = [cache objectAtIndex:0];
    if(fire_event)
      [self requestSuccessful:tag message:(NSString *)[messages objectForKey:tag]];
    cache=nil;
    return data;
  }
  return nil;
}

-(void)configureXSL:(NSString*)xsl xml:(NSString*)xml{
  if(xsl==XSL_PATH_MAIN_LIST)
  {
    // MetaHACK: extraemos los id de las noticias para poder navegarlas con gestures.
    // Lo retenemos en ids.
    NSString *txt = [self buildHtml:xml xsl:XSL_NOTICIAS_IDS];
    [YMobiPaperLib setIds:txt];
    txt=nil;
  }
  if(xsl==XSL_PATH_NEWS)
  {
    // MetaHACK: extraemos metadata de la noticia (como el web link). Lo asignamos en la propeidad metadata para que luego pueda ser consumido.
    NSString *txt = [self buildHtml:xml xsl:XSL_NOTICIA_METADATA];
    [self setMetadata:txt];
    txt=nil;
  }
}

// publica
-(NSData*) getHtmlAndConfigure:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag force_load:(BOOL)force_load {
  
  NSString* path = [self getUrl:item queryString:queryString];
  
  NSData* html_data = nil;
  
  if(force_load==NO && [self mustReloadPath:item queryString:queryString ]==NO)
  {
    NSLog(@"YMobiPaperLib::getHtmlAndConfigure No me fuerzan y no debo reloadearla");
    html_data = [self getChachedData:item queryString:queryString xsl:xsl tag:tag fire_event:NO is_html:YES];
    if(html_data!=nil)
    {
      path=nil;
      return html_data;
    }
  }
  
  if(html_data==nil)
  {
    html_data = [self getHtml:path xsl:xsl];
  }
  
  if(html_data!=nil)
  {
    NSData* xml_data = [self getChachedData:item queryString:queryString xsl:xsl tag:tag fire_event:NO is_html:NO];
    if(xml_data==nil)
    {
      path=nil;
      html_data=nil;
      return nil;
    }
    
    /*XMLParser *parser = [[XMLParser alloc]init];
    NSArray *images=[parser getImagesURLs:&xml_data];
    
    NSLog(@"%@", [[NSString alloc] initWithData:xml_data encoding:NSUTF8StringEncoding]);
    
    NSString* dir = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [[NSFileManager defaultManager] createFileAtPath:[dir stringByAppendingPathComponent: @"data_xml"] contents:xml_data attributes:nil];
    
    return nil;
    */
    
    [self configureXSL:xsl xml:[[NSString alloc] initWithData:xml_data encoding:NSUTF8StringEncoding]];
    path=nil;
    xml_data=nil;
  }
  
  return html_data;
}
 

+(void)setIds:(NSString*)text{
  _ids_de_noticias=nil;
  _ids_de_noticias=[[NSMutableArray alloc] initWithArray:[text componentsSeparatedByString:@";"] copyItems:YES];
  
}

+(NSString*)getNextNoticiaId:(NSString*)_noticia_id{
  if(_ids_de_noticias==nil)
  {
    return nil;
  }
  //_noticia_id = [_noticia_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
  NSUInteger index = [_ids_de_noticias indexOfObject:_noticia_id];
  if(index==NSNotFound)
    return nil;
  if ((index+1)<[_ids_de_noticias count]) {
    return [_ids_de_noticias objectAtIndex:(index+1)];
  }
  return nil;
}


+(NSString*)getPrevNoticiaId:(NSString*)_noticia_id
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
    return [_ids_de_noticias objectAtIndex:(index-1)];
  }
  return nil;
}

// Delegates
- (void)requestSuccessful:(id)argument message:(NSString*)message
{
  if (self.delegate==nil) {
		return;
  }
	[[self delegate] requestSuccessful:argument message:message];
}


- (void)requestFailed:(id)argument message:(NSString*)message
{
  if (self.delegate==nil) {
		return;
  }
	[[self delegate] requestFailed:argument message:message];
}

// Internet detector
-(BOOL)areWeConnectedToInternet{
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  [reachability startNotifier];
  NetworkStatus status = [reachability currentReachabilityStatus];
  [reachability stopNotifier];
  
  bool ret = NO;
  if(status == NotReachable)
  {
    //No internet
    NSLog(@"YMobiPaperLib::areWeConnectedToInternet No internet");
    ret= NO;
  }
  else if (status == ReachableViaWiFi)
  {
    //WiFi
    NSLog(@"YMobiPaperLib::areWeConnectedToInternet Wifi");
    ret= YES;
  }
  else if (status == ReachableViaWWAN)
  {
    //3G
    NSLog(@"YMobiPaperLib::areWeConnectedToInternet 3G");
    ret = YES;
  }
  reachability = nil;
  return ret;
}

@end
