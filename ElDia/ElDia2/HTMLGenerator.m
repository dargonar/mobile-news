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
#import "ErrorBuilder.h"

@implementation HTMLGenerator
- (NSData*)generate:(NSData*)xml  xslt_file:(NSString*)xslt_file error:(NSError**)error {

  xmlSubstituteEntitiesDefault(1);
	xmlLoadExtDtdDefaultValue = 1;

  if ( xslt_file == nil || xml == nil ) {
    return [ErrorBuilder build:error desc:@"invalid xlst param" code:ERR_INVALID_XSL_PARAM];
  }
  
  xsltStylesheetPtr cur = xsltParseStylesheetFile((const xmlChar *)[xslt_file UTF8String]);
	if (cur == nil || !cur) {
    return [ErrorBuilder build:error desc:@"xsltParseStylesheetFile nil" code:ERR_INVALID_XLS]; //HACK: ERR_INVALID_XSL 
  }
  
  const char *tmp = [xml bytes];
  int   len2      = [xml length];
  
  xmlDocPtr doc = xmlParseMemory(tmp,len2);
  
  if(doc==nil || !doc)
  {
    return [ErrorBuilder build:error desc:@"invalid xml" code:ERR_INVALID_XML];
  }
  
  xmlDocPtr res = xsltApplyStylesheet(cur, doc, NULL);
  if(doc==res || !res)
  {
    return [ErrorBuilder build:error desc:@"xsl transform error" code:ERR_XSL_TANSFORM];
  }
  
  xmlChar *html = 0;
  int len=0;
  
  xsltSaveResultToString(&html, &len, res, cur);
  
	xsltFreeStylesheet(cur);
	xmlFreeDoc(res);
	xmlFreeDoc(doc);
  
  xsltCleanupGlobals();
  xmlCleanupParser();
  
  if (html == nil || !html || len == 0 ) {
    return [ErrorBuilder build:error desc:@"html null or zero" code:ERR_GENERATED_HTML];
  }
  
  return   [NSData dataWithBytes:(const void *)html length:len];
}

@end
