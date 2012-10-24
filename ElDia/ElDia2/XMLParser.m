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

@implementation XMLParser


// Parseo el xml en busca de imagenes, las retorno en un array y modifico el path de la imagen.
-(NSArray*)extractImagesAndRebuild:(NSData**)xml_data{
  
  if (*xml_data == nil) {
    return nil;
  }
  
  //rss/channel/item/media:thumbnail@url
  
  NSError *error;
  GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:*xml_data options:0 error:&error];
  if (doc == nil)
  { return nil; }
  
  NSArray *items = [doc nodesForXPath:@"//rss/channel/item" error:nil];
  //NSLog(@"%@", doc.rootElement);
  NSMutableArray *mobi_images = [[NSMutableArray alloc] init];
  
  for (int i=0; i<[items count]; i++) {
    GDataXMLElement *item = (GDataXMLElement *)[items objectAtIndex:i];
    
    NSArray* temp_img = [item elementsForName:@"media:thumbnail"];
    if([temp_img count]!=1)
      continue;
    
    NSArray* temp = [item elementsForName:@"guid"];
    if([temp count]!=1)
      return nil;
    
    NSString* _url=[self urlAttribute:temp_img];
    NSString* _local_uri=[CryptoUtil sha1:_url];
    
    MobiImage* mobiImage = [MobiImage initWithData:_url
                                      _local_uri: _local_uri
                                      _noticia_id:[self firstElementAsString:temp]];
    
    [mobi_images addObject:mobiImage];
    
    [self setUrlAttribute:temp_img value:_local_uri];
   
    item=nil;
    _url=nil;
    _local_uri=nil;
    temp=nil;
    temp_img=nil;
  }
  
  GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:[doc rootElement]] ;
  *xml_data = nil;
  *xml_data = document.XMLData;
  doc=nil;
  document=nil;
  return [NSArray arrayWithArray:mobi_images];
}

-(void)setUrlAttribute:(NSArray*)elements value:(NSString*)value{
  //NSLog(@"setUrlAttribute antes de setear VALUE: %@",value);
  [[((GDataXMLElement*) [elements objectAtIndex:0]) attributeForName:@"url"] setStringValue:value];
  //NSLog(@"setUrlAttribute seteado?? VALUE: %@",[self urlAttribute:elements]);
  
}

-(NSString*)urlAttribute:(NSArray*)elements{
  return [((GDataXMLElement*) [elements objectAtIndex:0]) attributeForName:@"url"].stringValue;
}

-(NSString*)firstElementAsString:(NSArray*)elements{
  return ((GDataXMLElement*) [elements objectAtIndex:0]).stringValue;
}

@end