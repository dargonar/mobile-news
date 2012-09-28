//
//  SqliteCache.m
//  Massa
//
//  Created by Matias on 7/25/12.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import "SqliteCache.h"
#import "CryptoUtil.h"
#import <sqlite3.h>

@implementation SqliteCache

+ (SqliteCache *) defaultCache
{
  static SqliteCache *defaultCache = NULL;
  @synchronized(self)
  {
    if(defaultCache == NULL)
      defaultCache = [[SqliteCache alloc] init];
  }
  
  return defaultCache;
}

- (id)init {

  self = [super init];
  if (!self)
    return self;

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
  NSString *documentsDir = [paths objectAtIndex:0];
  NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"cache.sqlite"];
  
  //Always open
  sqlite3_open([dbPath cStringUsingEncoding:NSUTF8StringEncoding], &db);
  
  //Create table
  sqlite3_stmt *stm;
  sqlite3_prepare_v2(db, "CREATE TABLE IF NOT EXISTS cache (id VARCHAR(40) PRIMARY KEY, content BLOB, mimetype VARCHAR(40), created_at INTEGER);", -1, &stm, NULL);
  sqlite3_step(stm);
  sqlite3_finalize(stm);
  
  return self;

}

- (void)dealloc
{
  assert(db!=NULL);
  sqlite3_close(db);
	[super dealloc];
}


- (NSArray *)get:(NSString*)key {
  assert(db!=NULL);
  int err=0;
  sqlite3_stmt *stm;
  
  err=sqlite3_prepare_v2(db, "SELECT content,mimetype FROM cache where id = ?;", -1, &stm, NULL);
  assert(err==SQLITE_OK);
  
  err=sqlite3_bind_text(stm, 1, [[CryptoUtil sha1:key] UTF8String] , -1, SQLITE_STATIC);
  assert(err==SQLITE_OK);
  
  err=sqlite3_step(stm);
  if (err != SQLITE_ROW) {
    return nil;
  }
  
  NSData   *data = [NSData dataWithBytes:sqlite3_column_blob(stm, 0) length:sqlite3_column_bytes(stm, 0)];
  NSString *mime = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stm, 1)];
  err=sqlite3_finalize(stm);
  
  return [NSArray arrayWithObjects:data,mime,nil];
}

- (NSArray *)get:(NSString*)key since_hours:(int)since_hours{
  assert(db!=NULL);
  int err=0;
  sqlite3_stmt *stm;
  
  err=sqlite3_prepare_v2(db, "SELECT mimetype FROM cache where id = ? and created_at > ?;", -1, &stm, NULL);
  assert(err==SQLITE_OK);
  
  err=sqlite3_bind_text(stm, 1, [[CryptoUtil sha1:key] UTF8String] , -1, SQLITE_STATIC);
  assert(err==SQLITE_OK);
  
  int olddate = time(NULL) - since_hours*60*60;
  err=sqlite3_bind_int(stm, 2, olddate);
  assert(err==SQLITE_OK);
  
  err=sqlite3_step(stm);
  if (err != SQLITE_ROW) {
    return nil;
  }
  
  NSString *mime = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stm, 0)];
  err=sqlite3_finalize(stm);
  
  return [NSArray arrayWithObjects:mime,nil];
 
}

- (void)set:(NSString*)key data:(NSData *)data mimetype:(NSString*)mimetype {
  assert(db!=NULL);
  int err=0;
  sqlite3_stmt *stm;
  
  time_t currentTime = time(NULL);
  
  err=sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO cache (id,created_at,content,mimetype) VALUES (?,?,?,?);", -1, &stm, NULL);
  assert(err==SQLITE_OK);
  
  err=sqlite3_bind_text(stm, 1, [[CryptoUtil sha1:key] UTF8String], -1, SQLITE_STATIC);
  assert(err==SQLITE_OK);

  err=sqlite3_bind_int(stm, 2,  currentTime);
  assert(err==SQLITE_OK);
  
  err=sqlite3_bind_blob(stm, 3, [data bytes], [data length], SQLITE_STATIC);
  assert(err==SQLITE_OK);

  err=sqlite3_bind_text(stm, 4, [mimetype UTF8String], -1, SQLITE_STATIC);
  assert(err==SQLITE_OK);
  
  err=sqlite3_step(stm);
  assert(err=SQLITE_DONE);
  
  err=sqlite3_finalize(stm);
}

- (void)clean:(int)hours {

  assert(db!=NULL);
  int err=0;
  sqlite3_stmt *stm;
  
  int olddate = time(NULL) - hours*60*60;
  
  err=sqlite3_prepare_v2(db, "DELETE from cache where created_at < ?;", -1, &stm, NULL);
  assert(err==SQLITE_OK);
  
  err=sqlite3_bind_int(stm, 1, olddate);
  assert(err==SQLITE_OK);
  
  err=sqlite3_step(stm);
  assert(err=SQLITE_DONE);
  
  err=sqlite3_finalize(stm);
}


@end
