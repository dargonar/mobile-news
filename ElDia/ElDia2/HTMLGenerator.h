//
//  HTMLGeneratorWrapper.h
//  TestXSLT
//
//  Created by Matias on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//lo chorizzee de aca
//http://philjordan.eu/article/mixing-objective-c-c++-and-objective-c++

#import <Foundation/Foundation.h>

@interface HTMLGenerator : NSObject
- (NSData*)generate:(NSData*)xml  xslt_file:(NSString*)xslt_file;
@end
