//
//  XSLTParser.cpp
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

#include "HTMLGenerator.hpp"

std::string HTMLGenerator::generate(const std::string& xml, const std::string& xslt_file) {
  
  xmlSubstituteEntitiesDefault(1);
	xmlLoadExtDtdDefaultValue = 1;

  xsltStylesheetPtr cur = xsltParseStylesheetFile((const xmlChar *)xslt_file.c_str());
	
  xmlDocPtr doc = xmlParseMemory(xml.c_str(), xml.size());

  xmlDocPtr res = xsltApplyStylesheet(cur, doc, NULL);

  xmlChar *html = 0;
  int len=0;
  
  xsltSaveResultToString(&html, &len, res, cur);
  
	xsltFreeStylesheet(cur);
	xmlFreeDoc(res);
	xmlFreeDoc(doc);
  
  xsltCleanupGlobals();
  xmlCleanupParser();
  
  return std::string((char *)html);
}