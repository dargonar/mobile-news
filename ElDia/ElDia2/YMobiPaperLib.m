//
//  YMobiPaperLib.m
//  ElDia2
//
//  Created by Lion User on 28/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "YMobiPaperLib.h"
#import "RegexKitLite.h"

#define KEY_XSL @"key_xsl"
#define KEY_VIEW @"key_view"
#define KEY_TAG @"key_tag"
#define KEY_DATA @"key_data"

@implementation YMobiPaperLib

@synthesize urls, messages, requestsMetadata, delegate, metadata;

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
  }
	return self;
}

-(NSString *)getUrl:(YMobiNavigationType)item queryString:(NSString *)queryString{
  NSString *path = [urls objectAtIndex:(NSInteger)item];
  if ([queryString length]>0) {
    path = [[NSString alloc] initWithFormat:path,queryString];
  }
  return path;
}

-(void)loadHtml:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl  _webView:(UIWebView *) _webView {
  [self loadHtml:[self getUrl:item queryString:queryString] xsl:xsl _webView:_webView];
}


-(void)loadHtml:(NSString *)path xsl:(NSString *)xsl  _webView:(UIWebView *) _webView {
  
  NSData   *data     = nil;
  NSString *mimeType = nil;
  
  NSArray  *cache = [[SqliteCache defaultCache] get:path];
  if(cache) {
    data     = [cache objectAtIndex:0];
    mimeType = [cache objectAtIndex:1];
  }
  else {
    
    NSString *xml = [self loadURL:path];
    NSString *html = [self getHtml:xml xsl:xsl];
    //NSLog(@"HTML: [%@]", html);
    data     = [NSData dataWithBytes:[html UTF8String] length:[html length]+1];
    mimeType = @"text/html";
    [[SqliteCache defaultCache] set:path data:data mimetype:mimeType];
    
  }
  
  NSString *dirPath = [[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [_webView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:dirURL];

  //[data dealloc];
  data = nil;
  //[mimeType dealloc];
  mimeType = nil;

}

-(NSString *)loadURL:(NSString *)path{
  //HACK: Validar error!
  return [NSString stringWithContentsOfURL:[NSURL URLWithString:path] encoding:NSUTF8StringEncoding error:nil];

}

-(NSString *)getHtml:(NSString *)xml xsl:(NSString *)xsl{
  
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
  
  @try{
    // Limpiamos el XML quitandole los stributos class y style de las etiquetas.
    cleanedXML = [xml stringByReplacingOccurrencesOfRegex:htmlAttributesRegex withString:@"$1"];
    
    //Limpiamos otras mierdas
    //cleanedXML = [cleanedXML stringByReplacingOccurrencesOfString:@" & " withString:@" &amp;"];
    cleanedXML = [xml stringByReplacingOccurrencesOfRegex:undecodedAmpersandRegex withString:@"&amp;"];

    HTMLGenerator *generator = [[HTMLGenerator alloc] init];

    return [generator generate:cleanedXML xslt_file:path_xslt];
  }
  @catch (NSException * e) {
    [self requestFailed:nil message:e.reason];
  }
  @finally {
    //NSLog(@"finally");
  }
}

-(void)setHtmlToView:(UIWebView*)webView data:(NSData*)data mimeType:(NSString*)mimeType{
  if(webView==nil)
  {
    return;
  }
  NSString *dirPath = [[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [webView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:dirURL];
  
  //[data dealloc];
  data = nil;
  //[mimeType dealloc];
  mimeType = nil;
  dirPath=nil;
  dirURL=nil;
}

-(bool)mustReloadPath:(YMobiNavigationType)item queryString:(NSString *)queryString{
  if(item!=(int)YMobiNavigationTypeMain && item!=(int)YMobiNavigationTypeSectionNews && item!=(int)YMobiNavigationTypeSections)
    return NO;
  NSString* path = [self getUrl:item queryString:queryString];
  NSArray  *cache = [[SqliteCache defaultCache] get:path since_hours:1];
  if(cache) {
    return NO;
  }
  return YES;
}

- (void)cleanCache{
  //Deberiamos poder limpiar ciertas cosas y otras no.
  //Esto es: la data debe tener flags que indiquen el tipo de dato, mas alla del mimetype.
  @try{
    [[SqliteCache defaultCache] clean:48];
  }
  @catch (NSException * e) {
    [self requestFailed:nil message:e.reason];
  }
  @finally {
    //NSLog(@"finally");
  }
}

// Async implementation
-(void) loadHtmlAsync:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl  _webView:(UIWebView *) _webView tag:(NSString*)tag force_load:(BOOL)force_load {
  
  NSString* path = [self getUrl:item queryString:queryString];
  
  @try{
    if(force_load==NO && [self mustReloadPath:item queryString:queryString ]==NO)
    {
      NSArray  *cache = [[SqliteCache defaultCache] get:path];
      if(cache)
      {
        NSData   *data     =data     = [cache objectAtIndex:0];
        NSString *mimeType = mimeType = [cache objectAtIndex:1];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
          [self setHtmlToView:_webView data:data mimeType:mimeType];
        });
        [self requestSuccessful:tag message:(NSString *)[messages objectForKey:tag]];
        return;
      }
    }
  }
  @catch (NSException * e) {
    [self requestFailed:tag message:e.reason];
  }
  @finally {
    //NSLog(@"finally");
  }
  //Vinculo request con vista
  NSURL *theURL =  [[NSURL alloc]initWithString:path ];
  NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL
                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                timeoutInterval:60.0];
  
  NSMutableDictionary *_metadata = [[NSMutableDictionary alloc] init];
  [_metadata setValue:xsl forKey:KEY_XSL];
  [_metadata setValue:_webView forKey:KEY_VIEW];
  [_metadata setValue:tag forKey:KEY_TAG];
  
  NSMutableData *recv_data = [[NSMutableData alloc] init];
  [_metadata setValue:recv_data forKey:KEY_DATA];
  
  [requestsMetadata setValue:_metadata forKey:[NSString stringWithFormat:@"%i",[theRequest hash]]];
  
  [NSURLConnection connectionWithRequest:theRequest delegate:self];
  
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  
  [((NSMutableData *)[((NSMutableDictionary *)[requestsMetadata objectForKey:[NSString stringWithFormat:@"%i",[connection.originalRequest hash]]]) objectForKey:KEY_DATA]) appendData:data];
  
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSString*_key=[NSString stringWithFormat:@"%i",[connection.originalRequest hash]];
  NSMutableDictionary *_metadata = (NSMutableDictionary *)[requestsMetadata objectForKey:_key];
  NSString *tag = (NSString*)[_metadata objectForKey:KEY_TAG];
  
  [self requestFailed:tag message:(NSString *)[messages objectForKey:tag]];

  [requestsMetadata removeObjectForKey:_key];
  _key=nil;
  _metadata =nil;
  tag=nil;

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
  
  NSString*_key=[NSString stringWithFormat:@"%i",[connection.originalRequest hash]];
  NSMutableDictionary *_metadata = (NSMutableDictionary *)[requestsMetadata objectForKey:_key];
  NSMutableData * data = (NSMutableData*)[_metadata objectForKey:KEY_DATA];
  NSString *xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSString *xsl =(NSString*)[_metadata objectForKey:KEY_XSL];
  NSString *tag = (NSString*)[_metadata objectForKey:KEY_TAG];
  
  if(xsl==XSL_PATH_MAIN_LIST)
  {
    NSString *txt = [self getHtml:xml xsl:XSL_NOTICIAS_IDS];
    [YMobiPaperLib setIds:txt];
    txt=nil;
  }
  if(xsl==XSL_PATH_NEWS)
  {
    NSString *txt = [self getHtml:xml xsl:XSL_NOTICIA_METADATA];
    [self setMetadata:txt];
    txt=nil;
  }
  NSString *html = [self getHtml:xml xsl:xsl];
  if([xsl isEqualToString:XSL_PATH_SECTION_LIST])
    NSLog(@"%@", html);
  
  NSData *html_data     = [NSData dataWithBytes:[html UTF8String] length:[html length]+1];
  NSString*mimeType = @"text/html";
  
  @try {
    [[SqliteCache defaultCache] set:[[connection.originalRequest URL] absoluteString] data:html_data mimetype:mimeType];
  }
  @catch (NSException * e) {
  //[self requestFailed:tag message:e.reason];
   }
  @finally {
  //NSLog(@"finally");
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    [self setHtmlToView:(UIWebView*)[_metadata objectForKey:KEY_VIEW] data:html_data mimeType:mimeType];
  });
  //[self requestSuccessful:(NSString*)[metadata objectForKey:KEY_TAG] message:@"Proceso OK"];
    
  [self requestSuccessful:tag message:(NSString *)[messages objectForKey:tag]];
  
  html=nil;
  html_data=nil;
  mimeType=nil;
    
  
  [requestsMetadata removeObjectForKey:_key];
  data=nil;
  _metadata=nil;
  _key=nil;
  xml = nil;
  xsl=nil;
  tag=nil;
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


@end
