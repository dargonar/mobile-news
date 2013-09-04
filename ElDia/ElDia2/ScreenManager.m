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

NSString * const SERVICE_URL                          = @"http://www.diariosmoviles.com.ar/ws/screen?appid=%@&size=%@&ptls=%@&url=%@";

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
  return [cache createdAt:key prefix:@"s"];
}

-(NSDate*) menuClasificadosDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

-(NSDate*) clasificadosDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

-(NSDate*) farmaciaDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

-(NSDate*) carteleraDate:(NSString*)url {
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1:url];
  return [cache createdAt:key prefix:@"s"];
}

/**/
-(BOOL) menuExists{
  return [self screenExists:@"menu://" prefix:@"m"];
}

-(BOOL) menuClasificadosExists:(NSString*)url{
  return [self screenExists:url prefix:@"s"];
}

-(BOOL) clasificadosExists:(NSString*)url {
  return [self screenExists:url prefix:@"s"];
}

-(BOOL) funebresExists:(NSString*)url {
  return [self screenExists:url prefix:@"s"];
}

-(BOOL) farmaciaExists:(NSString*)url {
  return [self screenExists:url prefix:@"s"];
}

-(BOOL) carteleraExists:(NSString*)url {
  return [self screenExists:url prefix:@"s"];
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

// para iPad
-(BOOL) sectionMenuExists:(NSString*)url {
  NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_menu_"):(@"menu_");
  NSString *newUrl = [html_prefix stringByAppendingString:url];
  
  return [self screenExists:newUrl prefix:@"ms"];
}

/***********************************************************************************/

-(NSData *)getMenu:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:@"menu://" useCache:useCache processImages:NO prefix:@"m" error:error];
}

-(NSData *)getMenuClasificados:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"s" error:error];
}

-(NSData *)getClasificados:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"s" error:error];
}

-(NSData *)getFunebres:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"s" error:error];
}

-(NSData *)getFarmacia:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"s" error:error];
}

-(NSData *)getCartelera:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:NO prefix:@"s" error:error];
}

-(NSData *)getSection:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  return [self getScreen:url useCache:useCache processImages:YES prefix:@"s" error:error processNavigation:YES html_prefix:nil];
}

// para iPAd
-(NSData *)getSectionMenu:(NSString*)url useCache:(BOOL)useCache error:(NSError **)error{
  
//  NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_menu_"):(@"menu_");
//  //NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls"):(@"pt");
//  NSLog(@" ----------------------------  getSectionMenu()");
//  NSLog(@" url:[%@] html_prefix:[%@]", url, html_prefix );
//  return [self getScreen:url useCache:useCache processImages:YES prefix:@"m" error:error processNavigation:NO html_prefix:html_prefix];
  
  NSString *html_prefix= (isIpad && app_delegate.isLandscape)?(@"ls_menu_"):(@"menu_");
  NSString *newUrl = [html_prefix stringByAppendingString:url];
  return [self getScreen:newUrl useCache:useCache processImages:YES prefix:@"ms" error:error];

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
  
  NSString* composedHtmlPrefix = prefix;
  if(html_prefix!=nil)
  {
    composedHtmlPrefix = [NSString stringWithFormat:@"%@_%@",prefix, html_prefix];
  }
  
  DiskCache *cache = [DiskCache defaultCache];
  NSString  *key   = [CryptoUtil sha1: [[url componentsSeparatedByString:@"?"] objectAtIndex:0] ];
  
  NSLog(@"---------------- getScreen");
  NSLog(@" key[%@]; url[%@]; prefix:[%@].", key, url, composedHtmlPrefix);
  NSLog(@" useCache[%@].", useCache?@"SI":@"NOR");
  
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
  NSDictionary *response_dict =[self downloadUrl2:url error:&my_err];
  if(response_dict==nil)
    return [ErrorBuilder build:&my_err desc:@"No se pudo descargar la informacion" code:ERR_REQUEST_NULL];
  
  NSString *requestedHTML = [key stringByAppendingFormat:@".%@" ,composedHtmlPrefix];
  NSData* html = (NSData*)[response_dict objectForKey:requestedHTML];
  NSLog(@" requestedHTML[%@] is nil -> %@", requestedHTML, (html==nil)?@"SI":@"NOR");
  
//  //Lo guardamos y retornamos
//  if(![cache put:key data:html prefix:composedHtmlPrefix]) {
//    return [ErrorBuilder build:error desc:@"cache html" code:ERR_CACHING_HTML];
//  }

//  //Las imagenes a descargar.guardamos en cache
//  NSData *images = (NSData*)[response_dict objectForKey:@"images.txt"];
//  if(images!=nil)
//    if(![cache put:key data:images prefix:@"mi"])
//      return [ErrorBuilder build:error desc:@"cache mobimages" code:ERR_CACHING_MI];
  
  NSLog(@"------------------");
  NSLog(@" iterando contenidos de zipfiles");
  for(NSString* _key in response_dict)
  {
//    NSLog(@"--> file: %@", key);
//    if ([key rangeOfString:@"content.html"].location != NSNotFound) {
//      continue;
//    }
    NSData *data = (NSData*)[response_dict objectForKey:_key];
    if(data!=nil){
      if(![cache put2:_key data:data])
        return [ErrorBuilder build:error desc:@"cache file" code:ERR_CACHING_HTML];
      NSLog(@"--> SAVED %@", _key);
    }
    else{
      NSLog(@"--> NOT SAVED %@", _key);
    }
//    if ([key rangeOfString:@"menu"].location == NSNotFound) {
//      continue;
//    }
//    NSData *menu = (NSData*)[response_dict objectForKey:key];
//    if(menu!=nil){
//      NSString  *menu_key   = [CryptoUtil sha1:[key componentsSeparatedByString:@"."][0]];
//      if(![cache put:menu_key data:menu prefix:[key componentsSeparatedByString:@"."][1]])
//        return [ErrorBuilder build:error desc:@"cache mobimages" code:ERR_CACHING_HTML];
//    }
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

-(NSDictionary *)downloadUrl2:(NSString*)surl error:(NSError**)error  {
  
  NSURL *url = [self getXmlHttpUrl2:surl];
//  NSLog(@" ----------------- ");
//  NSLog(@" downloadUrl2: [%@] param:[%@]", [url absoluteString], surl);
//  NSLog(@" ----------------- ");
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  
  [request setNumberOfTimesToRetryOnTimeout:1];
  [request setTimeOutSeconds:15];
  [request setCachePolicy:ASIDoNotWriteToCacheCachePolicy|ASIDoNotReadFromCacheCachePolicy];
  request.timeOutSeconds=15;
  [request setShouldAttemptPersistentConnection:NO];
  
  [request startSynchronous];
  
  NSError *request_error = [request error];
  if (request_error) {
    if (error != nil) *error = request_error;
    return nil;
  }
  
  int code = [request responseStatusCode];
  NSLog(@" ----------------- ");
  NSLog(@" downloadUrl2: [%@] status:[%i]", [url absoluteString], code);
  NSLog(@" ----------------- ");
  if (code != 200) {
    return [ErrorBuilder build:error desc:@"server error" code:ERR_REQUEST_NULL];
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
  
  [unzipFile goToFirstFileInZip];
  ZipReadStream *read1= [unzipFile readCurrentFileInZip];
  NSData* file1 = [read1 readDataOfLength:[((FileInZipInfo*)[infos objectAtIndex:0]) length]];
  [read1 finishedReading];
  
  NSMutableDictionary *mdict = [[NSMutableDictionary alloc]init];
  [mdict setObject:file1 forKey:[((FileInZipInfo*)[infos objectAtIndex:0]) name]];
  
  NSInteger index = 1;
  while ([unzipFile goToNextFileInZip]) {
    ZipReadStream *read= [unzipFile readCurrentFileInZip];
    NSData*file = [read readDataOfLength:[((FileInZipInfo*)[infos objectAtIndex:index]) length]];
    [read finishedReading];
    [mdict setObject:file forKey:[((FileInZipInfo*)[infos objectAtIndex:index]) name]];
    index=index+1;
  }
  [unzipFile close];
  
  return  mdict;
  
}


-(NSURL*) getXmlHttpUrl2:(NSString*)url {
  
  NSString *newUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)url, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
  
  
//  NSString *escaped_url = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                                              (CFStringRef)url,
//                                                                              NULL,
//                                                                              CFSTR("!*'();:@&=+$,/?%#[]"),
//                                                                              kCFStringEncodingUTF8);
  
  NSString* tmp = [NSString stringWithFormat:SERVICE_URL,
                   [AppDelegate getBundleId],
                   ([app_delegate isiPad]?@"big":@"small"),
                   ([app_delegate isLandscape]?@"ls":@"pt"),
                   newUrl //[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   ];
  

  NSLog(@"----------------------------");
  NSLog(@"getXmlHttpUrl2: %@", tmp);
  return [NSURL URLWithString:tmp];

}

-(NSArray *)getPendingImages:(NSString*)url error:(NSError**)error {
  
//  NSString *key = [CryptoUtil sha1:url];
  NSString *key = [CryptoUtil sha1:[[url componentsSeparatedByString:@"?"] objectAtIndex:0]];
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
