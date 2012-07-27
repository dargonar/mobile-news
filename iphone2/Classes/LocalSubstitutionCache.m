//
//  LocalSubstitutionCache.m
//  LocalSubstitutionCache
//
//  Created by Matt Gallagher on 2010/09/06.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "LocalSubstitutionCache.h"
#import "SqliteCache.h"
#import "CryptoUtil.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation LocalSubstitutionCache

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
	 NSLog(@"salvamos para: %@", [[request URL] path]);
  [[SqliteCache defaultCache] set:[[request URL] path] data:[cachedResponse data]];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	//
	// Get the path for the request
	//
	NSString *pathString = [[request URL] absoluteString];
	NSLog(@"requieren un: %@", pathString);
  
  NSData *data = [[SqliteCache defaultCache] get:[CryptoUtil sha1:pathString]];
  if (!data) {
    NSLog(@"no lo tengo");
    return [super cachedResponseForRequest:request];
  }

  // Get the UTI from the file's extension:
  CFStringRef pathExtension = (__bridge_retained CFStringRef)[pathString pathExtension];
  CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
  CFRelease(pathExtension);
  
  // The UTI can be converted to a mime type:
  
  NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
  if (type != NULL)
    CFRelease(type);
  
	// Create the cacheable response
	//
	NSURLResponse *response =
		[[[NSURLResponse alloc]
			initWithURL:[request URL]
			MIMEType: mimeType
      expectedContentLength:[data length]
			textEncodingName:nil]
		autorelease];

  NSCachedURLResponse *cachedResponse =
		[[[NSCachedURLResponse alloc] initWithResponse:response data:data] autorelease];
	
	return cachedResponse;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{

}

- (void)dealloc
{
	[super dealloc];
}

@end
