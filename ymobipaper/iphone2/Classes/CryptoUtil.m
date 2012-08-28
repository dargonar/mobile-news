//
//  SHA1Util.m
//  Massa
//
//  Created by Matias on 7/24/12.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import "CryptoUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CryptoUtil

+(NSString*) sha1:(NSString*)input
{
  const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
  NSData *data = [NSData dataWithBytes:cstr length:input.length];
  
  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  
  CC_SHA1(data.bytes, data.length, digest);
  
  NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  
  for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
  
  return output;
  
}

+ (NSString *) md5:(NSString *) input
{
  const char *cStr = [input UTF8String];
  unsigned char digest[16];
  CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
  
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
  
  return  output;
  
}

@end
