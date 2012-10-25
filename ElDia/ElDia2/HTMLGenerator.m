//
//  HTMLGeneratorWrapper.m
//  TestXSLT
//
//  Created by Matias on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/DOCBparser.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>

#import "HTMLGenerator.h"

@implementation HTMLGenerator
- (NSData*)generate:(NSData*)xml  xslt_file:(NSString*)xslt_file {

  xmlSubstituteEntitiesDefault(1);
	xmlLoadExtDtdDefaultValue = 1;
  
  xsltStylesheetPtr cur = xsltParseStylesheetFile((const xmlChar *)[xslt_file UTF8String]);
	
  const char *tmp = [xml bytes];
  int   len2      = [xml length];
  
  xmlDocPtr doc = xmlParseMemory(tmp,len2);
  
  if(doc==nil || !doc)
  {
    NSLog(@"HTMLGenerator::generate INVALID XML");
    return nil;
  }
  
  xmlDocPtr res = xsltApplyStylesheet(cur, doc, NULL);
  if(doc==res || !res)
  {
    NSLog(@"HTMLGenerator::generate INVALID XSL");
    return nil;
  }
  
  xmlChar *html = 0;
  int len=0;
  
  xsltSaveResultToString(&html, &len, res, cur);
  
	xsltFreeStylesheet(cur);
	xmlFreeDoc(res);
	xmlFreeDoc(doc);
  
  xsltCleanupGlobals();
  xmlCleanupParser();
  
  return   [NSData dataWithBytes:(const void *)html length:len];
}

@end
