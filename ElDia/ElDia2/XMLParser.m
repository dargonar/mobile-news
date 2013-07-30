//
//  XMLParser.m
//  ElDia
//
//  Created by Lion User on 24/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "XMLParser.h"
#import "GDataXMLNode.h"
#import "MobiImage.h"
#import "CryptoUtil.h"
#import "ErrorBuilder.h"
#import "Base64.h"

@implementation XMLParser


-(NSDictionary* )getAdImageAndUrl:(NSData**)xml_data error:(NSError **)error{
  
  if (xml_data == nil || *xml_data == nil) {
    return [ErrorBuilder  build:error desc:@"invalid xml to parse" code:ERR_INVALID_XML];
  }
  
  //rss/channel/item/media:thumbnail@url
  
  GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:*xml_data options:0 error:error];
  if (doc == nil)
    return nil;
  
  NSArray *images = [doc nodesForXPath:@"//EplanningAds/Space/Ad/AdURL" error:nil];
  if (images == nil || [images count]<=0)
    return nil;
  NSString *ad_url = [self firstElementAsString:images];
  
  NSArray *urls = [doc nodesForXPath:@"//EplanningAds/Space/Ad/ClickThroughURL" error:nil];
  NSString *click_url = @"";
  if (urls != nil && [urls count]>0)
    click_url = [self firstElementAsString:urls];
  
  return [[NSDictionary alloc] initWithObjectsAndKeys:
            ad_url, @"ad_url",
            click_url, @"click_url",
            nil];
}

// Parseo el xml en busca de imagenes, las retorno en un array y modifico el path de la imagen.
-(NSArray*)extractImagesAndRebuild:(NSData**)xml_data error:(NSError **)error prefix:(NSString*)prefix{
  
  NSMutableArray *mobi_images = [[NSMutableArray alloc] init];
  
  if (xml_data == nil || *xml_data == nil) {
    return [ErrorBuilder  build:error desc:@"invalid xml to parse" code:ERR_INVALID_XML];
  }
  
  //rss/channel/item/media:thumbnail@url
  
  GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:*xml_data options:0 error:error];
  if (doc == nil)
    return nil;
  
  NSArray *items = [doc nodesForXPath:@"//rss/channel/item" error:nil];
  
  for (int i=0; i<[items count]; i++) {
    GDataXMLElement *item = (GDataXMLElement *)[items objectAtIndex:i];
    
    NSArray* temp_img = [item elementsForName:@"media:thumbnail"];
    if([temp_img count]!=1)
      continue;
    
    NSArray* temp = [item elementsForName:@"guid"];
    if([temp count]!=1)
      continue;
    
    NSString* _url=[self urlAttribute:temp_img];
    if (_url == nil)
      continue;

    NSString* _local_uri=[CryptoUtil sha1:_url];
    
    MobiImage* mobiImage = [MobiImage initWithData:_url
                                      _local_uri: _local_uri
                                      _noticia_id:[self firstElementAsString:temp]
                                      _prefix:prefix];
    
    [mobi_images addObject:mobiImage];
    
    [self setUrlAttribute:temp_img value:_local_uri];
  }
  
  GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:[doc rootElement]] ;
  if (document == nil) {
    return [ErrorBuilder build:error desc:@"generated xml" code:ERR_GENERATED_XML];
  }
  
  *xml_data = nil;
  *xml_data = document.XMLData;

  return [NSArray arrayWithArray:mobi_images];
}

-(BOOL)setUrlAttribute:(NSArray*)elements value:(NSString*)value {
  GDataXMLNode *node = [(GDataXMLElement*) [elements objectAtIndex:0] attributeForName:@"url"];
  if (node != nil) {
    [node setStringValue:value];
    return YES;
  }
  return NO;
}

-(NSString*)urlAttribute:(NSArray*)elements{
  GDataXMLNode *node = [(GDataXMLElement*) [elements objectAtIndex:0] attributeForName:@"url"];

  if (node == nil) {
      return nil;
  }
  
  return [node stringValue];
}

-(NSString*)firstElementAsString:(NSArray*)elements{
  return ((GDataXMLElement*) [elements objectAtIndex:0]).stringValue;
}

-(NSArray*)extractNewsUrls:(NSData*)xml_data error:(NSError **)error{
  
  //noticia://{$Node/guid}?url={$Node/link}&amp;title={$Node/title}&amp;header={$Node/description}
  NSMutableArray *news_urls = [[NSMutableArray alloc] init];
  
  if (xml_data == nil ) {
    return [ErrorBuilder  build:error desc:@"invalid xml to parse" code:ERR_INVALID_XML];
  }
  
  //rss/channel/item/media:thumbnail@url
  
  GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xml_data options:0 error:error];
  if (doc == nil)
    return nil;
  
  NSArray *items = [doc nodesForXPath:@"//rss/channel/item" error:nil];
  
  for (int i=0; i<[items count]; i++) {
    GDataXMLElement *item = (GDataXMLElement *)[items objectAtIndex:i];
    
    NSArray* temp_guid = [item elementsForName:@"guid"];
    if([temp_guid count]!=1)
      continue;
    
    NSArray* temp_link = [item elementsForName:@"link"];
    if([temp_link count]!=1)
      continue;
    
    NSArray* temp_title = [item elementsForName:@"title"];
    if([temp_title count]!=1)
      continue;

    NSArray* temp_header = [item elementsForName:@"description"];
    if([temp_header count]!=1)
      continue;
    /*
    NSLog(@"guid %@", [self firstElementAsString:temp_guid]);
    NSLog(@"link %@", [[self firstElementAsString:temp_link] base64EncodedString]);
    NSLog(@"title %@", [self firstElementAsString:temp_title]);
    NSLog(@"description %@", [self firstElementAsString:temp_header]);
    */
    
    /*
     NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"noticia://%@?url=%@&title=%@&header%@",
                                        [self firstElementAsString:temp_guid],
                                        [self firstElementAsString:temp_link],
                                        [self firstElementAsString:temp_title],
                                        [self firstElementAsString:temp_header]]];
    */
    
    NSURL * url = [NSURL URLWithString:[self URLEncodeString:
                   [NSString stringWithFormat:@"noticia://%@?url=%@&title=%@&header%@",
                                        [self firstElementAsString:temp_guid],
                                        [self firstElementAsString:temp_link],
                                        [self firstElementAsString:temp_title],
                                        [self firstElementAsString:temp_header]]]];
    [news_urls addObject:url];
    
  }
  
  return [NSArray arrayWithArray:news_urls];
}

-(NSString *) URLEncodeString:(NSString *) str
{
  
  NSMutableString *tempStr = [NSMutableString stringWithString:str];
  [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
  
  
  return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end