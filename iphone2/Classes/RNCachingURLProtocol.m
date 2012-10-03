//
//  RNCachingURLProtocol.m
//
//  Created by Robert Napier on 1/10/12.
//  Copyright (c) 2012 Rob Napier.
//
//  This code is licensed under the MIT License:
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "RNCachingURLProtocol.h"
#import "SqliteCache.h"

#import <MobileCoreServices/MobileCoreServices.h>

#define WORKAROUND_MUTABLE_COPY_LEAK 1

#if WORKAROUND_MUTABLE_COPY_LEAK
// required to workaround http://openradar.appspot.com/11596316
@interface NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround;

@end
#endif

static NSString *RNCachingURLHeader = @"X-DMCache";

@interface RNCachingURLProtocol () // <NSURLConnectionDelegate, NSURLConnectionDataDelegate> iOS5-only
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
- (void)appendData:(NSData *)newData;
@end

@implementation RNCachingURLProtocol
@synthesize connection = connection_;
@synthesize data       = data_;
@synthesize response   = response_;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  // only handle http requests we haven't marked with our header.
  if ([[[request URL] scheme] isEqualToString:@"http"] &&
      ([request valueForHTTPHeaderField:RNCachingURLHeader] == nil)) {
    return YES;
  }
  return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (void)startLoading
{
  NSString *key   = [[[self request] URL] absoluteString];
  NSArray *cache  = [[SqliteCache defaultCache] get:key];
  

  if ( !cache ) 
  {
    NSLog(@"Me piden: NO LATE : %@", key);
    NSMutableURLRequest *connectionRequest = 
#if WORKAROUND_MUTABLE_COPY_LEAK
      [[self request] mutableCopyWorkaround];
#else
      [[self request] mutableCopy];
#endif
    // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
    [connectionRequest setValue:@"" forHTTPHeaderField:RNCachingURLHeader];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:connectionRequest
                                                                delegate:self];
    [self setConnection:connection];
  }
  else 
  {
    NSLog(@"Me piden: SI LATE : %@", key);
    NSData   *data     = nil;
    NSString *mimeType = @"";

    data     = [cache objectAtIndex:0];
    mimeType = [cache objectAtIndex:1];    
    
    //
    NSURLResponse *response =
		[[[NSURLResponse alloc]
			initWithURL           : [[self request] URL]
			MIMEType              :  mimeType
      expectedContentLength : [data length]
			textEncodingName      :  nil]
     autorelease];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle ourselves.
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
  }
}

- (void)stopLoading
{
  [[self connection] cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [[self client] URLProtocol:self didLoadData:data];
  [self appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSString *key       = [[[self request] URL] absoluteString];
  NSLog(@"-X>Pedi/error %@", key);
  [[self client] URLProtocol:self didFailWithError:error];
  [self setConnection:nil];
  [self setData:nil];
  [self setResponse:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [self setResponse:response];
  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];  // We cache ourselves.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  [[self client] URLProtocolDidFinishLoading:self];

  NSString *key       = [[[self request] URL] absoluteString];
  NSData   *data      = [self data];
  NSString *mimeType  = [self mimeTypeForURL:[[self request] URL]];
  
  [[SqliteCache defaultCache] set:key data:data mimetype:mimeType];
  NSLog(@"-->Pedi/vino/guarde: %@", key);
  
  [self setConnection:nil];
  [self setData:nil];
  [self setResponse:nil];
}

- (void)appendData:(NSData *)newData
{
  if ([self data] == nil) {
    [self setData:[newData mutableCopy]];
  }
  else {
    [[self data] appendData:newData];
  }
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


@end

#if WORKAROUND_MUTABLE_COPY_LEAK
@implementation NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                          cachePolicy:[self cachePolicy]
                                                                      timeoutInterval:[self timeoutInterval]];
    [mutableURLRequest setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    return mutableURLRequest;
}

@end
#endif
