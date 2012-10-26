//
//  Utils.m
//  ElDia
//
//  Created by Lion User on 26/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "Utils.h"
#import "RegexKitLite.h"

@implementation Utils

+(NSString *)cleanUrl:(NSString*)url{
  NSString *escapedURL =  [[[[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"] stringByReplacingOccurrencesOfString:@"//" withString:@"/"] stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
  return escapedURL;
}

+(NSString *)getYoutubeId:(NSString*)url{
  
  NSString * local_url = [url stringByReplacingOccurrencesOfString:@"video://" withString:@"" ];
  local_url = [Utils cleanUrl:local_url];
  
  NSString *regex = @"^(?:https?://)?(?:www.)?(?:youtu.be/|youtube.com(?:/embed/|/v/|/watch\\?v=))([\\w-]{10,12})";
  NSArray *_ids = [local_url captureComponentsMatchedByRegex:regex];
  NSString *ret = @"";
  
  if ([_ids count]>1)
  {
    ret = [[NSString alloc] initWithFormat:@"%@",[_ids objectAtIndex:1]] ;
  }
  
  local_url=nil;
  regex=nil;
  _ids=nil;
  return ret;
}

+(NSData*)sanitizeXML:(NSData*)xml_data{
  
  NSString *cleanedXML = @"";
  
  NSString *xml = [[NSString alloc] initWithData:xml_data encoding:NSUTF8StringEncoding];
  
  NSString *htmlAttributesRegex = @"(?<=<)([^/>]+)(\\s(style|class)=['\"][^'\"]+?['\"])([^/>]*)(?=/?>|\\s)";
  //  source: http://www.andrewbarber.com/post/Remove-HTML-Attributes-and-Tags-from-HTML-Source.aspx
  //  (?<=<):                                 (-) starting '<', no matchea ningun grupo.
  //  ([^/>]+):                               (1) matchea todo lo que haya entre '<' y 'style="...'. Por ejemplot 'span font="12px;"  '.
  //  (\\s(style|class)=['\"][^'\"]+?['\"]):  (2) matchea 'style="<estilo>"', atributo entre comillas simples o dobles.
  //  ([^/>]*):                               (3) asegura que termina en espacio(' ') o en cierre de tag '>';
  //  (?=/?>|\\s):                            (-) aseguramos que se trata de un tag y metemos en el tercer cualquier otro atributo del tag.
  
  // Limpiamos el XML quitandole los stributos class y style de las etiquetas.
  cleanedXML = [xml stringByReplacingOccurrencesOfRegex:htmlAttributesRegex withString:@"$1"];
  
  NSString *undecodedAmpersandRegex = @"&(?![a-zA-Z0-9#]+;)" ; //@"/&(?![a-z#]+;)/i";
  //Limpiamos otras mierdas
  //cleanedXML = [cleanedXML stringByReplacingOccurrencesOfString:@" & " withString:@" &amp;"];
  cleanedXML = [xml stringByReplacingOccurrencesOfRegex:undecodedAmpersandRegex withString:@"&amp;"];
  
  htmlAttributesRegex = nil;
  undecodedAmpersandRegex = nil;
  
  //[NSData dataWithBytes:[xml UTF8String] length:[xml length]+1];
  //[xml dataUsingEncoding:NSUTF8StringEncoding] ;

  return [xml dataUsingEncoding:NSUTF8StringEncoding] ;
}

@end
