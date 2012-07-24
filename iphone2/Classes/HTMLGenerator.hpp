//
//  XSLTParser.h
//  TestXSLT
//
//  Created by Matias on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef TestXSLT_XSLTParser_h
#define TestXSLT_XSLTParser_h

#include <string>

class HTMLGenerator {
  
public:
  static std::string generate(const std::string& xml, const std::string& xslt_file);

};

#endif
