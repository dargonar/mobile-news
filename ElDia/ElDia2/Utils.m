//
//  Utils.m
//  ElDia
//
//  Created by Lion User on 26/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "Utils.h"
#import "RegexKitLite.h"
#import "Reachability.h"
#import "GTMNSString+HTML.h"

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
  return [Utils sanitizeXML:xml_data unescaping_html_entities:NO];
}

+(NSData*)sanitizeXML:(NSData*)xml_data unescaping_html_entities:(BOOL)unescaping_html_entities{


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
  
  //NSMutableString *invalidCharsString = [[NSMutableString alloc] init];
  //unichar character;
  //character = 0x07;
  //[invalidCharsString appendFormat:@"%C", character];
  //NSCharacterSet *invalidChars = [NSCharacterSet characterSetWithCharactersInString:invalidCharsString];
  //cleanedXML =[cleanedXML stringByTrimmingCharactersInSet:invalidChars];

  cleanedXML = [Utils validXMLString:cleanedXML ];
  
  if(unescaping_html_entities)
    cleanedXML = [cleanedXML gtm_stringByUnescapingFromHTML];
  
  htmlAttributesRegex = nil;
  undecodedAmpersandRegex = nil;
  
  //[NSData dataWithBytes:[xml UTF8String] length:[xml length]+1];
  //[xml dataUsingEncoding:NSUTF8StringEncoding] ;
  
  return [cleanedXML dataUsingEncoding:NSUTF8StringEncoding] ;
}

+ (NSString *)validXMLString:(NSString*)xml
{
    static NSCharacterSet *invalidXMLCharacterSet = nil;
  
  if (invalidXMLCharacterSet == nil)
  {
    // First, create a character set containing all valid UTF8 characters.
    NSMutableCharacterSet *xmlCharacterSet = [[NSMutableCharacterSet alloc] init];
    [xmlCharacterSet addCharactersInRange:NSMakeRange(0x9, 1)];
    [xmlCharacterSet addCharactersInRange:NSMakeRange(0xA, 1)];
    [xmlCharacterSet addCharactersInRange:NSMakeRange(0xD, 1)];
    [xmlCharacterSet addCharactersInRange:NSMakeRange(0x20, 0xD7FF - 0x20)];
    [xmlCharacterSet addCharactersInRange:NSMakeRange(0xE000, 0xFFFD - 0xE000)];
    [xmlCharacterSet addCharactersInRange:NSMakeRange(0x10000, 0x10FFFF - 0x10000)];
    
    // Then create and retain an inverted set, which will thus contain all invalid XML characters.
    invalidXMLCharacterSet = [xmlCharacterSet invertedSet] ;
    xmlCharacterSet=nil;
  }
  
  // Are there any invalid characters in this string?
  NSRange range = [xml rangeOfCharacterFromSet:invalidXMLCharacterSet];
  
  // If not, just return self unaltered.
  if (range.length == 0)
    return xml;
  
  // Otherwise go through and remove any illegal XML characters from a copy of the string.
  NSMutableString *cleanedString = [xml mutableCopy];
  
  while (range.length > 0)
  {
    [cleanedString deleteCharactersInRange:range];
    range = [cleanedString rangeOfCharacterFromSet:invalidXMLCharacterSet options:NSCaseInsensitiveSearch range:NSMakeRange(range.location, [cleanedString length] - range.location)];
    
  }
  
  return cleanedString;
}

// Internet detector
+(BOOL)areWeConnectedToInternet{
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  //[reachability startNotifier];
  NetworkStatus status = [reachability currentReachabilityStatus];
  //[reachability stopNotifier];
  
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

+ (NSString *)timeAgoFromUnixTime:(double)seconds
{
  double difference = [[NSDate date] timeIntervalSince1970] - seconds;
  NSMutableArray *periods = [NSMutableArray arrayWithObjects:@"segundo", @"minuto", @"hora", @"dia", @"semana", @"mes", @"año", @"década", nil];
  NSArray *lengths = [NSArray arrayWithObjects:@"60", @"60", @"24", @"7", @"4.35", @"12", @"10", nil];
  int j = 0;
  for(j=0; difference >= [[lengths objectAtIndex:j] doubleValue]; j++)
  {
    difference /= [[lengths objectAtIndex:j] doubleValue];
  }
  difference = roundl(difference);
  
  if(difference != 1)
  {
    [periods insertObject:[[periods objectAtIndex:j] stringByAppendingString:@"s"] atIndex:j];
  }
  if(j==0)
  {
    return @"Recién actualizado";
  }
  return [NSString stringWithFormat:@"Actualizado hace %li %@", (long)difference, [periods objectAtIndex:j]];
}

@end
