//
//  ErrorBuilder.m
//  ElDia
//
//  Created by Matias on 10/25/12.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "ErrorBuilder.h"

@implementation ErrorBuilder

+(id) build:(NSError **)error desc:(NSString *)desc code:(NSInteger)code {
  
  if (error != nil) {
    *error = [NSError errorWithDomain:@"mobi" 
                                 code:code 
                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedDescriptionKey, desc, nil]];
  }
  return nil;
}

@end
