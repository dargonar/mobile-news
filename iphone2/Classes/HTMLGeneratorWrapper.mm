//
//  HTMLGeneratorWrapper.m
//  TestXSLT
//
//  Created by Matias on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTMLGeneratorWrapper.h"
#import "HTMLGenerator.hpp"

@interface HTMLGeneratorWrapper() {
  HTMLGenerator wrapped;  
}
@end;

@implementation HTMLGeneratorWrapper
- (NSString*)generate:(NSString*)xml  xslt_file:(NSString*)xslt_file {

  std::string cpp_xml([xml UTF8String], [xml lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
  std::string cpp_xslt_file([xslt_file UTF8String], [xslt_file lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
  
  std::string cpp_html = wrapped.generate(cpp_xml, cpp_xslt_file);
  
  return [[NSString alloc] initWithCString:cpp_html.c_str() encoding:NSUTF8StringEncoding];
}
@end
