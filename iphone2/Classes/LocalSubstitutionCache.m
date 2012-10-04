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
#import "MyCachedResponse.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation LocalSubstitutionCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	//
	// Get the path for the request
	//
	NSString *pathString = [[request URL] absoluteString];
	NSLog(@"Requieren: %@", pathString);
  
  NSData   *data     = nil;
  NSString *mimeType = @"";
  
  NSArray *cache = [[SqliteCache defaultCache] get:pathString];
  if (cache) {
    data     = [cache objectAtIndex:0];
    mimeType = [cache objectAtIndex:1];
    NSLog(@"Lo tengo [mime]=%@", mimeType);
  }
  else {
    NSLog(@"No lo tengo, lo busco");
    data     = [NSData dataWithContentsOfURL:[request URL]];
    
    if(!data)
    {
      NSLog(@"Error trayendo me voy con nil");
      return nil;
    }

    mimeType = [self mimeTypeForURL:[request URL]];
    [[SqliteCache defaultCache] set:pathString data:data mimetype:mimeType];
    
    NSLog(@"-->Lo encontre [mime]=%@", mimeType);
  }
  
	// Create the cacheable response
	//
	NSURLResponse *response =
		[[[NSURLResponse alloc]
			initWithURL           : [request URL]
			MIMEType              :  mimeType
      expectedContentLength : [data length]
			textEncodingName      :  nil]
		autorelease];

//  MyCachedResponse *cachedResponse =
//		[[[MyCachedResponse alloc] initWithResponse:response data:data] autorelease];
//	
	return (id)cachedResponse;
}

-(NSString*) mimeTypeForURL: (NSURL *) url {

  // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
  // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
  CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[url pathExtension], NULL);
  CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
  CFRelease(UTI);
  if (!mimeType) {
    return @"application/octet-stream";
  }
  return [NSMakeCollectable((NSString *)mimeType) autorelease];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{

}

- (void)dealloc
{
	[super dealloc];
}

@end
