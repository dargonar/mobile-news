//
//  SqliteCache.h
//  Massa
//
//  Created by Matias on 7/25/12.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqliteCache : NSObject {
  sqlite3 *db;
}

+ (SqliteCache *) defaultCache;
- (NSArray *) get   : (NSString*)key;
- (NSArray *)get:(NSString*)key since_hours:(int)since_hours;
- (void)      set   : (NSString*)key data:(NSData*)data mimetype:(NSString*)mimetype;
- (void)      clean : (int)hours;
@end
