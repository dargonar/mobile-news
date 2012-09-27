//
//  YMobiPaperLib.m
//  ElDia2
//
//  Created by Lion User on 28/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "YMobiPaperLib.h"
#import "RegexKitLite.h"

@implementation YMobiPaperLib

@synthesize urls;

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

  }
	return self;
}

-(NSString *)getUrl:(YMobiNavigationType *)item queryString:(NSString *)queryString{
  NSString *path = [urls objectAtIndex:(NSInteger)item];
  
  if ([queryString length]>0) {
    path = [[NSString alloc] initWithFormat:path,queryString];
  }
  NSLog(@"YMobiPaperLib::getUrl path:%@", path);
  
  return path;
}

-(void)loadHtml:(YMobiNavigationType *)item queryString:(NSString *)queryString xsl:(NSString *)xsl  _webView:(UIWebView *) _webView {
  
  NSLog(@"YMobiPaperLib::loadHtml");
  [self loadHtml:[self getUrl:item queryString:queryString] xsl:xsl _webView:_webView];
}

-(void) removeLongPressGestureRecognizers:(UIView *)view{
  for (id object in view.gestureRecognizers) {
    UIGestureRecognizer *gesture =  (UIGestureRecognizer *)object;
    if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
      gesture.enabled=NO;
    }
  }
  for (id _view in view.subviews) {
    for (id object in ((UIView *)_view).gestureRecognizers) {
      UIGestureRecognizer *gesture =  (UIGestureRecognizer *)object;
      if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gesture.enabled=NO;
      }
    }
  }
}

-(void)loadHtml:(NSString *)path xsl:(NSString *)xsl  _webView:(UIWebView *) _webView {
  
  //HACK aca?
  /*
   [self removeLongPressGestureRecognizers:_webView];
  */
  
  NSData   *data     = nil;
  NSString *mimeType = nil;
  
  NSArray  *cache = [[SqliteCache defaultCache] get:path];
  if(cache) {
    data     = [cache objectAtIndex:0];
    mimeType = [cache objectAtIndex:1];
    //NSLog(@"loadHTML-1 : CACHED!!");
  }
  else {
    
    //NSLog(@"loadHTML-1 : NOT CACHED; url: %@", path);
    
    NSString *html = [self gethtml:path xsl:xsl];
    //NSLog(@"loadHTML [%@]",html);
    data     = [NSData dataWithBytes:[html UTF8String] length:[html length]+1];
    mimeType = @"text/html";
    [[SqliteCache defaultCache] set:path data:data mimetype:mimeType];
    
  }
  NSLog(@"loadHTML-2 : cargando la vista");
  
  //[_webView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:dirURL];

  
  NSString *dirPath = [[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  
  [_webView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:dirURL];

  
  //NSURL *mainBundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
  //[_webView loadHTMLString:(@"main bundle: '%s'",[mainBundleURL path]) baseURL:mainBundleURL];
  
  //[data dealloc];
  data = nil;
  //[mimeType dealloc];
  mimeType = nil;

}


-(NSString *)gethtml:(NSString *)path xsl:(NSString *)xsl{
  
  //HACK: Validar error!
  NSString *xml = [NSString stringWithContentsOfURL:[NSURL URLWithString:path] encoding:NSUTF8StringEncoding error:nil];
  NSString* path_xslt = [[NSBundle mainBundle] pathForResource:xsl  ofType:@"xsl"];

  // Limpiamos el XML quitandole los stributos class y style de las etiquetas.
  NSString *regexTotal2 = @"(?<=<)([^/>]+)(\\s(style|class)=['\"][^'\"]+?['\"])([^/>]*)(?=/?>|\\s)";
  //  source: http://www.andrewbarber.com/post/Remove-HTML-Attributes-and-Tags-from-HTML-Source.aspx
  //  (?<=<):                                 (-) starting '<', no matchea ningun grupo.
  //  ([^/>]+):                               (1) matchea todo lo que haya entre '<' y 'style="...'. Por ejemplot 'span font="12px;" '.
  //  (\\s(style|class)=['\"][^'\"]+?['\"]):  (2) matchea 'style="<estilo>"', atributo entre comillas simples o dobles.
  //  ([^/>]*):                               (3) asegura que termina en espacio(' ') o en cierre de tag '>';
  //  (?=/?>|\\s):                            (-) aseguramos que se trata de un tag y metemos en el tercer cualquier otro atributo del tag.
                                   
  NSString *cleanedXML = @"";
  
  cleanedXML = [xml stringByReplacingOccurrencesOfRegex:regexTotal2 withString:@"$1"];
  
 /*
  // Por ahora limpiamos solo si la consulta es de noticia abierta.
  if (xsl==NEWS_XSL_PATH) {
      
    cleanedXML = [xml stringByReplacingOccurrencesOfRegex:regexTotal2 withString:@"$1"];
    //NSLog(@"cleanedXML: '%@'", cleanedXML);
    //Logeamos los elementos matcheados.
    NSUInteger  line         = 0UL;
    for(NSString *matchedString in [xml componentsMatchedByRegex:regexTotal2]) {
      NSLog(@"--)MATCHED: %lu: %lu '%@'", (u_long)++line, (u_long)[matchedString length], matchedString);
    }
  }
  else{
    NSLog(@"   regex: es listado PAPA!");
    cleanedXML = xml;
  }
  */
  
  HTMLGenerator *generator = [[HTMLGenerator alloc] init];

  NSString *html = [generator generate:cleanedXML xslt_file:path_xslt];
  /*if (xsl==NEWS_XSL_PATH) {
    NSLog(@" HTML: '%@'", html);
  }*/
  return html;
}
@end
