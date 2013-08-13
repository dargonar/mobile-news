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

#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

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
NSString * const iPad_MAIN_NEWS_PT_STYLESHEET         = @"2_tablet_noticias_index_portrait.xsl";
NSString * const iPad_MAIN_NEWS_LS_STYLESHEET         = @"2_tablet_noticias_index_landscape.xsl";
//NSString * const iPad_NOTICIA_PT_STYLESHEET           = @"3_tablet_new_portrait.xsl";  // NO SE USA
NSString * const iPad_NOTICIA_PT_STYLESHEET           = @"3_tablet_new_global.xsl";
NSString * const iPad_NOTICIA_LS_STYLESHEET           = @"3_tablet_new_landscape.xsl"; // NO SE USA
NSString * const iPad_NOTICIAS_REL_PT_STYLESHEET      = @"3_tablet_new_relateds_portrait.xsl"; // NO SE USA
NSString * const iPad_NOTICIAS_REL_LS_STYLESHEET      = @"3_tablet_new_relateds_landscape.xsl"; // NO SE USA
NSString * const iPad_MENU_STYLESHEET                 = @"4_tablet_menu_secciones.xsl"; 
NSString * const iPad_CLASIFICADOS_STYLESHEET         = @"5_tablet_clasificados.xsl";
NSString * const iPad_FUNEBRES_STYLESHEET             = @"6_tablet_funebres.xsl";
NSString * const iPad_FARMACIAS_STYLESHEET            = @"7_tablet_farmacias.xsl";
NSString * const iPad_CARTELERA_STYLESHEET            = @"8_tablet_cartelera.xsl";


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
  if([prefix isEqualToString:@"a"] || [prefix isEqualToString:@"s"])
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
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"sm" error:error processNavigation:NO html_prefix:html_prefix];
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
  
  NSLog(@" url[%@]; prefix:[%@].", url, composedHtmlPrefix);
  
  //Si piden ver la cache
  if (useCache) {

    NSData *html = [cache get:key prefix:composedHtmlPrefix];
    if (html != nil) {
//      if(processNavigation)
//      {
//        [self processNewsForGestureNavigation:key];
//      }
      return html;
    }
  }
  
  if(![Utils areWeConnectedToInternet])
  {
    return [ErrorBuilder build:error desc:@"no internet conection" code:ERR_NO_INTERNET_CONNECTION];
  }
  
  //Lo bajo
  NSError *my_err;
  NSArray *response_array =[self downloadUrl2:url error:&my_err];

  // response[0] -> html
  // response[1] -> CSImages_urls

  NSData* html = (NSData*)[response_array objectAtIndex:0];
  //Lo guardamos y retornamos
  if(![cache put:key data:html prefix:composedHtmlPrefix]) {
    return [ErrorBuilder build:error desc:@"cache html" code:ERR_CACHING_HTML];
  }

  //Las imagenes a descargar.guardamos en cache
  if([response_array count]>1)
  {
    NSData* images= (NSData*)[response_array objectAtIndex:1];
    if (images != nil)
      if(![cache put:key data:images prefix:@"mi"]) {
        return [ErrorBuilder build:error desc:@"cache mobimages" code:ERR_CACHING_MI];
      }
  }
//  if(processNavigation)
//  {
//    [self processNewsForGestureNavigation:xml dummy:NO];
//  }
  
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

-(NSArray *)downloadUrl2:(NSString*)surl error:(NSError**)error  {
  
  NSURL *url = [self getXmlHttpUrl2:surl];
  NSLog(@" ----------------- ");
  NSLog(@" downloadUrl2: [%@] param:[%@]", [url absoluteString], surl);
  NSLog(@" ----------------- ");
  
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
  
  NSString  *key   = [CryptoUtil sha1:[url absoluteString]];
  DiskCache *cache = [DiskCache defaultCache];
  
  if(![cache put:key data:response prefix:@"zip"])
    return nil;

  NSString* zipFilename = [cache getFileName:key prefix:@"zip"];

  ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:zipFilename mode:ZipFileModeUnzip];
  NSArray *infos= [unzipFile listFileInZipInfos];
  
//  NSMutableArray *file_sizes = [[NSMutableArray alloc] init];
//  for (FileInZipInfo *info in infos) {
//    [file_sizes addObject: [NSString stringWithFormat:@"%d", info.size ]];
//  }
  
  BOOL first_file_is_html = [[((FileInZipInfo*)[infos objectAtIndex:0]) name] hasSuffix:@"html"];
  
  [unzipFile goToFirstFileInZip];
  ZipReadStream *read1= [unzipFile readCurrentFileInZip];
  NSData* file1 = [read1 readDataOfLength:[((FileInZipInfo*)[infos objectAtIndex:0]) length]];
  [read1 finishedReading];
  
  NSData* file2 = nil;
  if ([unzipFile goToNextFileInZip])
  {
    ZipReadStream *read2= [unzipFile readCurrentFileInZip];
    file2 = [read2 readDataOfLength:[((FileInZipInfo*)[infos objectAtIndex:1]) length]];
    [read2 finishedReading];
  }
  [unzipFile close];
  
//  return  [NSArray arrayWithArray:[[NSMutableArray alloc] initWithObjects:content, extra, nil]];
  NSMutableArray* ret = [[NSMutableArray alloc] init];
  if(file2 != nil)
  {
    if(first_file_is_html)
    {
      [ret addObject:file1];
      [ret addObject:file2];
    }
    else
    {
      [ret addObject:file2];
      [ret addObject:file1];
    }
  
  }
  else
    [ret addObject:file1];

  return  [NSArray arrayWithArray:ret];
  
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
  
  if( [url hasPrefix:@"menu_section://"] ) {
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

-(NSURL*) getXmlHttpUrl2:(NSString*)url {
  NSString* tmp = [NSString stringWithFormat:@"http://192.168.1.101:8095/ws/screen?appid=com.diventi.eldia&size=%@&ptls=%@&url=%@",
                      ([app_delegate isiPad]?@"big":@"small"),
                      ([app_delegate isLandscape]?@"ls":@"pt"),
                      url
                   ];
  return [NSURL URLWithString:tmp];

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
  
  NSArray *mobi_images_raw = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
  
  if (mobi_images_raw == nil || [mobi_images_raw count]==0) {
    return [ErrorBuilder build:error desc:@"unarchive failed" code:ERR_DESERIALIZING_MI];
  }
  
  NSMutableArray *mobi_images = [[NSMutableArray alloc]init];
  
  for (int i=0; i<[mobi_images_raw count]; i++) {
    NSString *img_url= (NSString*)[mobi_images_raw objectAtIndex:i];
    MobiImage *image = [MobiImage initWithData:img_url _local_uri: [CryptoUtil sha1:img_url] _noticia_id:@"" _prefix:@"i"];
    if( ![cache exists:image.local_uri prefix:@"i"] )
      [mobi_images addObject:image];
  }
  return mobi_images;
}

@end
